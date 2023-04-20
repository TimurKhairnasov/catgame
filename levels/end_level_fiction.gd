extends AnimatedSprite2D

@onready var animation_player = $AnimationPlayer
@onready var sound_swoosh = $Swoosh

var is_close = false
func _on_close(body):
	if is_close:
		return
	is_close = true
	sound_swoosh.play()
	play("close")
	animation_player.play("light_close")
