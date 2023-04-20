extends AnimatedSprite2D

var damage = 1
var active := false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var blow_animation = $Blow
var damagable_body

func _ready():
	play("idle")

func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
		damagable_body = body

func blow():
	play("idle")
	blow_animation.play("blow")
	if damagable_body == null:
		return
	var vector: Vector2
	if damagable_body.position.x > position.x:
		vector = Vector2(70, 0)
	else:
		vector = Vector2(-70, 0)
	var hp = damagable_body.take_damage(damage, vector)
	damagable_body = null

func _on_area_2d_2_body_entered(body):
	if active:
		active = false
		blow()

func _on_area_2d_body_exited(body):
	damagable_body = null
	
func drop():
	active = true
	play("drop")
