extends Node2D

# Attributes
var time := 0.0
var can_play := true

## Child nodes
@onready var background: Sprite2D = $Background
@onready var desk: Sprite2D = $Desk
@onready var door: Sprite2D = $Door
@onready var player: AnimatedSprite2D = $Player
@onready var audio: AudioStreamPlayer = $Audio

# Methods
## Overriden methods
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# Timeline
	if time > 25:
		get_tree().change_scene_to_file("res://scenes/level1.tscn")
	elif time > 22:
		player.play("walking_left", 2)
		player.position.x -= delta * 60
	elif time > 20:
		player.play("facing_right")
	elif time > 18.1:
		player.position.x += delta * 60
		player.play("walking_right", 2)
	elif time > 18:
		background.texture = load("res://assets/cutscene/boss_room.png")
		door.visible = true
		desk.visible = false
		player.position = Vector2(-150, 45)
	elif time > 13.8:
		player.position.x += delta * 60
		player.play("walking_right", 2)
	elif time > 13:
		player.play("idle")
	elif time > 12:
		player.position.y += delta * 20
		player.play("idle")
		move_child(player, 3)
	elif time > 10:
		player.position.x -= delta * 30
		player.play("walking_left")
	elif time > 8.5:
		$Desk.texture = load("res://assets/cutscene/desk.png")
	elif time > 5:
		$Desk.texture = load("res://assets/cutscene/desk2.png")

	# Audio timeline
	if time > 5.6:
		can_play = true
	elif time > 5.4:
		if can_play:
			audio.play()
			can_play = false

	time += delta
