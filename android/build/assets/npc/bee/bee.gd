extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var animation_player = $AnimationPlayer
@onready var area_follow = $FollowArea/CollisionShape2D
@onready var collision = $CollisionShape2D
@onready var area_attack = $AttackArea/CollisionShape2D

@onready var sound_chase = $SoundEffects/chase
@onready var sound_death = $SoundEffects/death
@onready var sound_attack = $SoundEffects/attack

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

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
			_die(delta)
			return
			
	move_and_slide()

var last_prod = 0
func _chase_player(delta): #chasing player
	
	if !sound_chase.playing:
		sound_chase.play()
	_play_animation("fly")
	velocity = global_position.direction_to(player.global_position) * SPEED
	var direction = -1

	if velocity.x > 0:
		direction = 1
		self.scale.x = scale.y * -direction
	elif velocity.x < 0:
		direction = -1
		self.scale.x = scale.y * -direction
		
	last_direction = direction
	move_and_collide(velocity)	
 
func _idle(delta): #idling state
	
	velocity.x = move_toward(velocity.x, 0, SPEED)	
	_play_animation("fly")
		
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
	_play_animation("attack")
	area_follow.set_deferred("disabled", true)
	set_state(STATES.PATROLING)

func take_a_hit():
	die()
	
func die():
	if not is_attack:
		set_state(STATES.DEAD)
	
var is_dead = false
func _die(delta):
	if is_dead and is_on_floor():
		collision.set_deferred("disabled", true)
		return
	elif is_dead:
		velocity.x = 0
		velocity.y += gravity * delta
		move_and_slide()
		return
	is_dead = true
	_play_animation("death")
	sound_death.play()
	animation_player.play("dying_rotate")
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
	set_state(STATES.ATTACK)
	sound_attack.play()
	is_attack = true
	var vector: Vector2
	if body.position.x > position.x:
		vector = Vector2(50, 0)
	else:
		vector = Vector2(-50, 0)
	var hp = body.take_damage(damage, vector)
	await get_tree().create_timer(1).timeout
	is_attack = false
	if hp == 0:
		player = null
		set_state(STATES.IDLE)

func _on_detection(body):
	set_state(STATES.CHASING)
	print("_on_detection")
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
