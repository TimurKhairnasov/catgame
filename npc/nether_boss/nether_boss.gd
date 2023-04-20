extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var line = $Line
@onready var area_follow = $FollowArea/CollisionShape2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 

const SPEED = 300
const JUMP_VELOCITY = -400.0
const PATROLING_SPEED = 30.0

enum STATES { IDLE, CHASING, PATROLING, PEERING, ANIMATION }

var current_state = [STATES.IDLE, STATES.PATROLING] 

var current_speed := [0.0, 0.0]
var player: Node2D
var last_direction := -1.0

var global_position_y = null

signal on_peering

func _process(delta):
	match get_current_state():
		STATES.PEERING:
			_on_peering_state(delta)
			
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
			
	move_and_slide()
	
func _on_peering_state(delta):
	if global_position.x > player.global_position.x:
		animated_sprite.flip_h = true
	elif global_position.x < player.global_position.x:
		animated_sprite.flip_h = false

func _chase_player(delta): #chasing player
	velocity = global_position.direction_to(player.global_position)
	if global_position.x > player.global_position.x:
		animated_sprite.flip_h = true
	elif global_position.x < player.global_position.x:
		animated_sprite.flip_h = false
		
	move_and_collide(velocity)	
 
func _idle(delta): #idling state
	
	velocity.x = move_toward(velocity.x, 0, SPEED)	
		
var pase = 0
func _patroling(delta):
	if global_position_y == null:
		global_position_y = global_position.y
		
	if global_position_y < global_position.y:
		velocity.y -= 0.5
	else:
		area_follow.set_deferred("disabled", false)
		velocity.y = 0.0
	
	if (velocity.x > 0):
		animated_sprite.flip_h = false
	elif (velocity.x < 0):
		animated_sprite.flip_h = true
	
	velocity.x = last_direction * PATROLING_SPEED
	
	pase += 1
	if pase%100 == 0:
		last_direction = -last_direction

func set_state(state):
	if current_state[1] == state:
		return
	current_state = [current_state[1], state]
	
func get_current_state():
	return current_state[1]
	
func get_previous_state():
	return current_state[0]
	
func follow():
	if player != null:
		set_state(STATES.PEERING)
	
func _on_detection(body):
	if get_current_state() != STATES.ANIMATION:
		set_state(STATES.CHASING)
	player = body

func _on_loss(body): # player lost by enemy
	player = null

	set_state(STATES.IDLE)
		
	# if there is no player - start patroling
	await get_tree().create_timer(5).timeout
		
	if get_current_state() == STATES.IDLE:
		set_state(STATES.PATROLING)

func _on_peering(body):
	if get_current_state() != STATES.ANIMATION:
		emit_signal("on_peering")
		set_state(STATES.PEERING)
	

func _on_stop_peering(body):
	set_state(STATES.CHASING)

func flip():
	animated_sprite.flip_h = !animated_sprite.flip_h
	
func set_animated_state():
	set_state(STATES.ANIMATION)

func set_patroling():
	set_state(STATES.PATROLING)
	
func set_line_text(text):
	return line.set_line_text(text)
