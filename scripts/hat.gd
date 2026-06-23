extends CharacterBody2D

# Attributes
var direction := 1
var speed := 300
var acceleration := 8
var timer := 0.0
var thrower: Node2D

# Methods
## Overriden methods
func _ready() -> void:
	$Sprite.play("spinning")

func _physics_process(delta: float) -> void:
	# Updating velocity
	speed -= acceleration
	velocity.x = speed * direction

	# Updating movement
	move_and_slide()

	# Dying after a while
	if timer > 1.5:
		die()

	# Updating timer
	timer += delta

## New methods
func die() -> void:
	queue_free()
	thrower.has_hat = true

## Signal methods
func touched_thrower(_body: Node2D) -> void:
	die()
