extends Node

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
