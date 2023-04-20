extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var sound_chase = $soundEffects/chase
@onready var sound_death = $soundEffects/death
@onready var area_follow = $FollowArea/CollisionShape2D
@onready var collision = $CollisionShape2D
@onready var area_attack = $AttackArea/CollisionShape2D

const SPEED = 2

const JUMP_VELOCITY = -400.0
const PATROLING_SPEED = 30.0

enum STATES { IDLE, DEAD, CHASING, PATROLING, ATTACK }

var current_state = [STATES.IDLE, STATES.PATROLING] 

var current_speed := [0.0, 0.0]
var is_attack = false
var player: Node2D
var last_direction := -1.0
var damage := 1

var global_position_y = null

func _process(delta):
	
	if is_attack: # if enemy attacking right now
		attack()
		move_and_slide()
		return
		
	match get_current_state():
		STATES.PATROLING:
			_patroling(delta)
			
		STATES.IDLE:
			_idle(delta)
		
		STATES.CHASING:
			if player:
				_chase_player(delta)
				return
			else:
				_idle(delta)
	
		STATES.DEAD:
			_die()
			return
			
	move_and_slide()

func _chase_player(delta): #chasing player
	if !sound_chase.playing: 
		sound_chase.play()
	_play_animation("move")
	velocity = global_position.direction_to(player.global_position) * SPEED
	var direction = -1

	if velocity.x > 0:
		direction = 1
		self.scale.x = scale.y * direction
	elif velocity.x < 0:
		direction = -1
		self.scale.x = scale.y * direction
		
	last_direction = direction
	
	move_and_collide(velocity)	
 
func _idle(delta): #idling state
	
	velocity.x = move_toward(velocity.x, 0, SPEED)	
	_play_animation("idle")
		
var pase = 0
func _patroling(delta):
	if global_position_y == null:
		global_position_y = global_position.y
		
	if global_position_y < global_position.y:
		velocity.y -= 0.5
	else:
		area_follow.set_deferred("disabled", false)
		velocity.y = 0.0
		
	_play_animation("fly")
	
	velocity.x = last_direction * PATROLING_SPEED
	
	self.scale.x = scale.y * -last_direction
	
	pase += 1
	if pase%100 == 0:
		last_direction = -last_direction

func attack():
	velocity = Vector2(0, 0)	
	_play_animation("move")
	area_follow.set_deferred("disabled", true)
	set_state(STATES.PATROLING)

func take_a_hit():
	die()

func die():
	sound_death.play()
	if not is_attack:
		set_state(STATES.DEAD)
	
var is_dead = false
func _die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2(0, 0)
	_play_animation("death")
	collision.set_deferred("disabled", true)
	area_attack.set_deferred("disabled", true)
	area_follow.set_deferred("disabled", true)
	player = null

func set_state(state):
	if current_state[1] == state:
		return
	current_state = [current_state[1], state]
	
func get_current_state():
	return current_state[1]
	
func get_previous_state():
	return current_state[0]
	
func _play_animation(animation: String):
	if (animated_sprite.animation != animation):
		animated_sprite.play(animation)

func _on_attack(body: CharacterBody2D):
	if is_attack:
		return
	set_state(STATES.PATROLING)
	is_attack = true
	var vector: Vector2
	if body.position.x > position.x:
		vector = Vector2(70, 0)
	else:
		vector = Vector2(-70, 0)
	var hp = body.take_damage(damage, vector)
	is_attack = false
	player = null


func _on_detection(body):
	set_state(STATES.CHASING)
	player = body

func _on_loss(body): # player lost by enemy
	sound_chase.stop()
	player = null
	if get_current_state() != STATES.DEAD:
		set_state(STATES.IDLE)
		
		# if there is no player - start patroling
		await get_tree().create_timer(5).timeout
		
		if get_current_state() == STATES.IDLE:
			set_state(STATES.PATROLING)
