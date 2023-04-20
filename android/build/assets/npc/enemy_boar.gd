extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@onready var sound_chase = $soundsEffects/chase
@onready var sound_death = $soundsEffects/dead
@onready var sound_attack = $soundsEffects/attack

@onready var area_follow = $FollowArea/CollisionShape2D
@onready var collision = $CollisionShape2D
@onready var area_attack = $AttackArea/CollisionShape2D
@onready var area_detection = $DetectionArea/CollisionShape2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

var damage := 1

var player_position
var target_position
var player: Node2D

enum STATES { IDLE, RUNNUNG, DEAD, CHASING, PATROLING }

var is_attack = false
var is_dead = false

var current_state = [STATES.IDLE, STATES.PATROLING] 

const SPEED = 100.0
const PATROLING_SPEED = 30.0
const STEP = 5.0
var current_speed := 0.0
var last_direction := -1.0

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
			else:
				_idle(delta)
	
		STATES.DEAD:
			_die()
			return
	
	move_and_slide()

var pase = 0
func _patroling(delta):
	if not is_on_floor():
		_play_animation("fall")
		velocity.y += gravity * delta
	elif is_on_wall():
		_play_animation("idle")
	else:
		_play_animation("run")
	
	velocity.x = last_direction * PATROLING_SPEED
	
	self.scale.x = scale.y * last_direction
	
	pase += 1
	if pase%100 == 0:
		last_direction = -last_direction
	
func _idle(delta): #idling state
	if current_speed - STEP <= 0:
		current_speed = 0
		velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		current_speed -= STEP
		velocity.x = last_direction * current_speed
		
	if not is_on_floor():
		_play_animation("fall")
		velocity.y += gravity * delta
	else:
		_play_animation("idle")
		
func _chase_player(delta): #chasing player
	if !sound_chase.playing:
		sound_chase.play()
	if not is_on_floor():
		_play_animation("fall")
		velocity.y += gravity * delta
	elif is_on_wall():
		_play_animation("idle")
	else:
		_play_animation("run")
	
	velocity.x = global_position.direction_to(player.global_position)[0]
	
	var direction = -1

	if velocity.x > 0:
		direction = 1
		self.scale.x = scale.y * direction
	elif velocity.x < 0:
		direction = -1
		self.scale.x = scale.y * direction
	
	if last_direction != direction:
		current_speed = STEP
		last_direction = direction
	elif current_speed + STEP >= SPEED:
		current_speed = SPEED
	else:
		current_speed += STEP
		
	velocity.x *= current_speed
	last_direction = direction
 
func _play_animation(animation: String):
	if (animated_sprite.animation != animation):
		animated_sprite.play(animation)

func take_a_hit():
	die()
	
func die():
	if not is_attack:
		set_state(STATES.DEAD)
	
func _die():
	if is_dead:
		return
	is_dead = true
	sound_death.play()
	velocity = Vector2(0, 0)
	_play_animation("death")
	area_follow.set_deferred("disabled", true)
	collision.set_deferred("disabled", true)
	area_attack.set_deferred("disabled", true)
	area_detection.set_deferred("disabled", true)
	player = null

func _on_attack(body: CharacterBody2D):
	if is_attack:
		return
	sound_attack.play()
	is_attack = true
	var vector: Vector2
	if body.position.x > position.x:
		vector = Vector2(70, 0)
	else:
		vector = Vector2(-70, 0)
	var hp = body.take_damage(damage, vector)
	await get_tree().create_timer(1).timeout
	is_attack = false
	if hp == 0:
		player = null
		set_state(STATES.IDLE)
	
func attack():
	velocity = Vector2(0, 0)	
	_play_animation("attack")

func _on_detection(body): # player found by enemy
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
	
func set_state(state):
	if current_state[1] == state:
		return
	current_state = [current_state[1], state]
	
func get_current_state():
	return current_state[1]
	
func get_previous_state():
	return current_state[0]

func _on_peakes_damage(body):
	die()
