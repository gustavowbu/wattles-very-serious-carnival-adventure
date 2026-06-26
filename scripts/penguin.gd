extends CharacterBody2D
class_name Penguin

# Attributes
## Exported attributes
@export var color: String

## Movement
var max_speed = 1
var acceleration = 0.1
var gravity = 50
var max_falling_speed = 15

## State attributes
var movement := 0
var cooldown := 0.0

## Child nodes
@onready var sprite: AnimatedSprite2D = $Sprite

# Methods
## Overriden methods
func _ready() -> void:
	# Multiplying the values by the tile size
	max_speed *= 32
	acceleration *= 32
	gravity *= 32
	max_falling_speed *= 32

	cooldown = randi_range(2, 4)

func _physics_process(delta: float) -> void:
	# Updating state
	if cooldown <= 0:
		if movement == 0:
			movement = randi_range(0, 1) * 2 - 1
			cooldown = randi_range(1, 3)
		else:
			movement = 0
			cooldown = randi_range(2, 4)

	# Updating velocity
	## walking
	if movement and movement * velocity.x <= max_speed:
		velocity.x = move_toward(velocity.x, movement * max_speed, acceleration)
	## losing momentum on ground
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, acceleration * 4.0)
	## losing momentum on air
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration / 4.0)

	## Gravity
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, max_falling_speed, gravity * delta)

	# Updating position
	move_and_slide()

	# Updating cooldown
	cooldown -= delta

	# Updating animations
	if movement == 0:
		sprite.play("idle")
	elif movement > 0:
		sprite.play("walking_right")
	else:
		sprite.play("walking_left")
