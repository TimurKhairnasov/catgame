extends MarginContainer

@onready var button_click = $ButtonClick
@onready var sprite = $VBoxContainer/AnimatedSprite2D
@onready var animation_player = $AnimationPlayer

signal death_screen_shown

func _ready():
	
	self.visible = false
	match GlobalPlayerState.get_skin():
		0:
			sprite.play("skin_1")
		1:
			sprite.play("skin_2")
		2:
			sprite.play("skin_3")
		3:
			sprite.play("skin_4")
		4:
			sprite.play("skin_5")

func _restart():
	print("restart")
	button_click.play()
	animation_player.play("outro")
	await get_tree().create_timer(1).timeout
	toggle_visibility(false)
	Global.restart()
	
func toggle_visibility(visible: bool):
	if visible:
		emit_signal("death_screen_shown")
	self.visible = visible

func _on_player_dead():
	toggle_visibility(true)

func _main_menu():
	print("_main_menu")
	button_click.play()
	animation_player.play("outro")
	await get_tree().create_timer(1).timeout
	Global.go_to_main_menu()
