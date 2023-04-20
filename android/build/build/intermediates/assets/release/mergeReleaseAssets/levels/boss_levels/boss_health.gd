extends MarginContainer

@onready var hp_container = $MarginContainer/HPMargin/HPContainer
@onready var hp_texture = preload("res://assets/Red_rectangle.png")

func hp_changed(hp: int):
	var current_hp = hp_container.get_child_count()
	if hp > current_hp:
		for i in range(hp - current_hp):
			var texture_rect = TextureRect.new()
			texture_rect.texture = hp_texture
			hp_container.add_child(texture_rect)
	elif hp < current_hp: 
		for i in range(current_hp - hp):
			hp_container.remove_child(hp_container.get_child(0))
		if current_hp == 0:
			visible = false
