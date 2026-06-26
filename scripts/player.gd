extends CharacterBody2D

# Attributes
var direction := 1

## Movement attributes
var max_speed = 5
var acceleration = 0.5
var jump_velocity = 14
var propel_velocity = 9
var gravity = 50
var max_falling_speed = 15

## Memory attributes
var can_dive = true
var diving = false
var can_propel = true
var propelling = false
var propel_cooldown := 0.0

var has_hat := true

## Child nodes
@onready var hat_sprite: AnimatedSprite2D = $Hat
@onready var sprite: AnimatedSprite2D = $Sprite

# Methods
## Overriden methods
func _ready() -> void:
	# Multiplying the values by the tile size
	max_speed *= 32
	acceleration *= 32
	jump_velocity *= 32
	propel_velocity *= 32
	gravity *= 32
	max_falling_speed *= 32

func _physics_process(delta: float) -> void:
	# Updating state
	## Key presses
	var movement := Input.get_axis("move_left", "move_right")
	var jump := Input.is_action_just_pressed("jump")
	var dive := Input.is_action_just_pressed("dive")
	var propel := Input.is_action_just_pressed("propel")
	var throw := Input.is_action_just_pressed("throw")

	## Movement state
	var wall_sliding := movement and is_on_wall() and velocity.y > 0

	if is_on_floor():
		can_dive = true
		can_propel = true
		diving = false
	if propel and can_propel and has_hat:
		can_propel = false
		propelling = true
		propel_cooldown = 0.35

	## Other state variables
	if movement:
		direction = int(movement)

	# Updating velocity
	## gravity
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_falling_speed, gravity * delta)

	## walking
	if movement and movement * velocity.x <= max_speed:
		velocity.x = move_toward(velocity.x, movement * max_speed, acceleration)
	## losing momentum on ground
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, acceleration * 4.0)
	## losing momentum on air
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration / 4.0)

	## wall sliding
	if wall_sliding:
		velocity.y = 80
		if jump and Global.can_wall_jump:
			velocity.x = 2 * max_speed * -movement
		diving = false

	## propelling
	if propelling and Global.can_propel:
		velocity.x = 0
		velocity.y = -propel_velocity
		propel_cooldown -= delta
		if propel_cooldown <= 0:
			propelling = false
		diving = false

	## jumping
	if jump and (is_on_floor() or (wall_sliding and Global.can_wall_jump)):
		velocity.y = -jump_velocity

	## diving
	if dive and can_dive and not propelling and not is_on_floor() and Global.can_dive:
		velocity.y = -jump_velocity / 1.5
		velocity.x = 2 * max_speed * direction
		can_dive = false
		diving = true

	## throwing hat
	if throw and has_hat and Global.can_throw:
		has_hat = false
		var hat: Node2D = load("res://scenes/hat.tscn").instantiate()
		hat.thrower = self
		if wall_sliding:
			direction *= -1
		hat.position = position + Vector2(direction * 32, -8)
		hat.direction = direction
		if wall_sliding:
			direction *= -1
		get_parent().add_child(hat)

	# Updating position
	move_and_slide()

	# Updating animation
	if is_on_floor():
		## idle and walking
		if movement == 0:
			sprite.play("idle")
		elif movement > 0:
			sprite.play("walking_right")
		else:
			sprite.play("walking_left")
	else:
		## jumping and propelling
		if movement == 0 or propelling:
			sprite.play("jumping_front")
		elif movement > 0:
			sprite.play("jumping_right")
		else:
			sprite.play("jumping_left")

	hat_sprite.position = Vector2(-1, -37)
	## diving
	if diving:
		if velocity.x > 0:
			sprite.play("diving_right")
			hat_sprite.position = Vector2(7, -32)
		else:
			sprite.play("diving_left")
			hat_sprite.position = Vector2(-8, -32)

	## wall sliding
	if wall_sliding:
		if movement > 0:
			sprite.play("wall_sliding_right")
		else:
			sprite.play("wall_sliding_left")

	## hat
	if not has_hat:
		hat_sprite.play("no_hat")
	elif velocity != Vector2(0, 0):
		if propelling:
			hat_sprite.play("spinning", 5)
		else:
			hat_sprite.play("spinning", 1)
	else:
		hat_sprite.play("spinning")
		hat_sprite.pause()

## Signal methods
func _on_death_collision_area_entered(_area: Area2D) -> void:
	get_tree().reload_current_scene.call_deferred()

func _on_feet_bounced(area: Area2D) -> void:
	velocity.y = -jump_velocity
	var parent = area.get_parent()
	if parent.type == "hat":
		if parent.jumped_once:
			parent.die()
		parent.jumped_once = true
