extends Node

# Attributes
## Movement attributes
var can_wall_jump := true
var can_spin_jump := true
var can_propel := true
var can_throw := true
var can_dive := true

# Methods
## Overriden methods
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		var current_mode = DisplayServer.window_get_mode()
		var fullscreen = DisplayServer.WINDOW_MODE_FULLSCREEN
		var windowed = DisplayServer.WINDOW_MODE_WINDOWED
		if current_mode == fullscreen:
			DisplayServer.window_set_mode(windowed)
		else:
			DisplayServer.window_set_mode(fullscreen)
