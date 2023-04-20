extends AnimatedSprite2D

@onready var attack_area = $Attack/CollisionShape2D
@onready var sound_shot = $Shot

var is_attack = false
var damage = 1

func shoot():
	play("attack")
	sound_shot.play()
	await get_tree().create_timer(.24).timeout
	attack_area.disabled = false
	await get_tree().create_timer(.12).timeout
	attack_area.disabled = true
	
func _on_attack(body: CharacterBody2D):
	if is_attack:
		return
		
	is_attack = true
	var vector: Vector2
	if body.position.x > position.x:
		vector = Vector2(70, 0)
	else:
		vector = Vector2(-70, 0)
	var hp = body.take_damage(damage, vector)
	await get_tree().create_timer(1).timeout
	is_attack = false
