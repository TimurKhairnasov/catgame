extends MarginContainer

@onready var button_click = $ButtonClick
@onready var music = $music
@onready var animation_player = $AnimationPlayer

func _ready():
	music.play()

func start_game():
	button_click.play()
	animation_player.play("outro")
	await get_tree().create_timer(1).timeout
	music.stop()
	Global.start_new_game()

func exit_game():
	button_click.play()
	music.stop()
	Global.exit_game()
