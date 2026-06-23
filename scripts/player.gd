extends CharacterBody2D

# Attributes
var direction := 1

## movement attributes
var max_speed = 5
var acceleration = 0.5
var jump_velocity = 14
var propel_velocity = 9
var gravity = 50
var max_falling_speed = 15

## memory attributes
var can_dive = true
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
	var movement := Input.get_axis("move_left", "move_right")
	var jump := Input.is_action_just_pressed("jump")
	var dive := Input.is_action_just_pressed("dive")
	var propel := Input.is_action_just_pressed("propel")
	var throw := Input.is_action_just_pressed("throw")
	var wall_sliding := movement and is_on_wall() and velocity.y > 0

	if movement:
		direction = int(movement)

	if is_on_floor():
		can_dive = true
		can_propel = true
	if propel and can_propel and has_hat:
		can_propel = false
		propelling = true
		propel_cooldown = 0.35
	if not has_hat:
		propelling = false

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

	## propelling
	if propelling and Global.can_propel:
		velocity.x = 0
		velocity.y = -propel_velocity
		propel_cooldown -= delta
		if propel_cooldown <= 0:
			propelling = 0

	## jumping
	if jump and (is_on_floor() or (wall_sliding and Global.can_wall_jump)):
		velocity.y = -jump_velocity

	## diving
	if dive and can_dive and not propelling and not is_on_floor() and Global.can_dive:
		velocity.y = -jump_velocity / 1.5
		velocity.x = 2 * max_speed * direction
		can_dive = false

	## Throwing hat
	if throw and has_hat and Global.can_throw:
		has_hat = false
		var hat: Node2D = load("res://scenes/hat.tscn").instantiate()
		hat.thrower = self
		hat.position = position + Vector2(direction * 32, -8)
		hat.direction = direction
		get_parent().add_child(hat)

	# Updating position
	move_and_slide()

	# Updating animation
	if movement == 0 or propelling:
		sprite.play("idle")
	elif movement > 0:
		sprite.play("walking_right")
	else:
		sprite.play("walking_left")

	if not is_on_floor():
		sprite.play("jumping")

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

func _on_feet_touched_hat(_area: Area2D) -> void:
	velocity.y = -jump_velocity
