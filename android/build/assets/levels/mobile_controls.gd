extends CanvasLayer

@onready var jump = $jump
@onready var left = $left
@onready var right = $right
@onready var pause = $pause

func hide_buttons():
	jump.visible = false
	left.visible = false
	right.visible = false
	
func show_buttons():
	jump.visible = true
	left.visible = true
	right.visible = true
	pause.visible = true

func _on_death_screen_death_screen_shown():
	jump.visible = false
	left.visible = false
	right.visible = false
	pause.visible = false
