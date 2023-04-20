extends MarginContainer

@onready var resume = $MarginContainer/VBoxContainer/Resume
@onready var main_menu = $MarginContainer/VBoxContainer/MainMenu
@onready var sound = $MarginContainer/ButtonClick
@onready var animation_player = $AnimationPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	Global.connect("on_pause_state_change", toogle_visibility)
	var animation = animation_player.get_animation("fade")
	animation_player.play("fade")
	animation_player.seek(animation.length)
	
func toogle_visibility(is_on: bool):
	print("toogle_visibility ")
	if is_on:
		animation_player.play("fade_in")
	else:
		animation_player.play("fade")
	resume.disabled = !is_on
	main_menu.disabled = !is_on

func _on_resume_pressed():
	sound.play()
	Global.toggle_pause()

func _on_main_menu_pressed():
	sound.play()
	Global.go_to_main_menu()
