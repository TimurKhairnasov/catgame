extends Node2D

@onready var intro_outro_player = $IntroOutroPlayer
@onready var music = $music

# Called when the node enters the scene tree for the first time.
func _ready():
	intro_outro_player.play("intro")
	music.play()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_area_2d_end_level():
	intro_outro_player.play("outro")
	await get_tree().create_timer(1).timeout
	music.stop()
	Global.go_to_next_level()
