extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

var player_position
var target_position
var player: Node2D

const PATROLING_SPEED = 30.0
var current_speed := 0.0
var last_direction := -1.0
var damage = 1

func _process(delta):
	
	_patroling(delta)
	
	move_and_slide()

var pase = 0
func _patroling(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	_play_animation("run")
	
	velocity.x = last_direction * PATROLING_SPEED
	
	self.scale.x = scale.y * last_direction
	
	pase += 1
	if pase%150 == 0:
		last_direction = -last_direction
		
func _play_animation(animation: String):
	if (animated_sprite.animation != animation):
		animated_sprite.play(animation)

func _on_attack(body: CharacterBody2D):
	last_direction = -last_direction
	var vector: Vector2
	if body.position.x > position.x:
		vector = Vector2(70, 0)
	else:
		vector = Vector2(-70, 0)
	body.take_damage(damage, vector)
