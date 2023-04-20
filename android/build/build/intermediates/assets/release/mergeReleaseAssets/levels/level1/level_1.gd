extends Node2D

@onready var music = $music
@onready var intro_outro_player = $IntroOutroPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	music.play()
	intro_outro_player.play("intro")


func _on_end_level_end_level():
	intro_outro_player.play("outro")
	await get_tree().create_timer(1).timeout
	music.stop()
	Global.go_to_next_level()
