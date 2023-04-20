extends CharacterBody2D


const SPEED = 30.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

enum STATES { IDLE, RUNNUNG, DEAD, CHASING, PATROLING }
var last_direction = -1
var pase = 0
var current_state = STATES.RUNNUNG

var heal := 1

func _process(delta):
	
	match current_state:
		STATES.RUNNUNG:
			_running(delta)
			
		STATES.IDLE:
			_idle(delta)
	
		STATES.DEAD:
			_die()
			return
	
	move_and_slide()
	
func _die():
	velocity = Vector2(0, 0)
	_play_animation("death")
	$KillingArea/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	
func _running(delta):
	if not is_on_floor():
		_play_animation("run")
		velocity.y += gravity * delta
	else:
		_play_animation("run")
	
	velocity.x = last_direction * SPEED
	
	self.scale.x = scale.y * last_direction
	
	pase += 1
	if pase%100 == 0:
		last_direction = -last_direction

func _idle(delta): #idling state
	velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if not is_on_floor():
		_play_animation("fall")
		velocity.y += gravity * delta
	else:
		_play_animation("idle")

func die():
	current_state = STATES.DEAD

@onready var animated_sprite = $AnimatedSprite2D
func _play_animation(animation: String):
	if (animated_sprite.animation != animation):
		animated_sprite.play(animation)

func _on_kill(body: CharacterBody2D):
	print("on_kill")
	body.take_heal(heal)
	die()
