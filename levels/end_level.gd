extends AnimatedSprite2D

signal end_level

func go_to_next_level(body: Node2D):
	emit_signal("end_level")
