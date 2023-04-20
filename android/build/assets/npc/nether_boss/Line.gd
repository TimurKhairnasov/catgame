extends Label

var tween

const SPEED = 0.02

# Called when the node enters the scene tree for the first time.
func set_line_text(text):
	if tween:
		tween.kill()
	
	visible_ratio = 0.0
	self.text = text
	tween = get_tree().create_tween()
	var duration = SPEED*text.length()
	tween.tween_property(self, "visible_ratio", 1.0, duration)
	play_sound(true)
	tween.tween_method(play_sound, true, false, duration)
	return duration
	
func play_sound(is_playing: bool):
	if is_playing:
		$Typing.play()
	else:
		$Typing.stop()
	
