class_name PlayerState

const DEAD = "dead"
const IDLE = "idle"
const RUN = "run"
const WALK = "walk"
const JUMP = "jump"
const FALL = "fall"
const ATTACK = "attack"
const IDLE_LIE_DOWN = "idle_lie_down"

enum State { STATE_PLAYABLE, STATE_NOT_PLAYABLE, STATE_ANIMATION_SCENE }

const JUMP_PRESSED = 0
const JUMP_RELEASED = 1
const JUMP_NONE = -1

const JUMP_VELOCITY = -350.0
const JUMP_ACCUMULATION_STEP = 30
const JUMP_LIMITATION = 5

const STEP = 10.0
const SPEED = 150.0

var direction = [0, 0]

var action = [JUMP_NONE, JUMP_NONE]
var last_velocity = 0

var time_in_air = 0

var _speed := 0.0

var _current_state = [IDLE, IDLE]

var _is_attack = false
var is_invinsible = false

var state = State.STATE_PLAYABLE


#movement
func set_action(direction, is_jump_pressed, is_jump_released):
	self.direction[1] = direction
	if is_jump_pressed:
		action = [action[1], JUMP_PRESSED]
	elif is_jump_released:
		action = [action[1], JUMP_RELEASED]
	else:
		action = [action[1], JUMP_NONE]


#jump
var is_jumped = false
func is_jump(is_on_floor):
	if is_on_floor:
		is_jumped = false
		time_in_air = 0
	else:
		time_in_air += 1
	var is_jump = action[1] == JUMP_PRESSED && time_in_air < JUMP_LIMITATION && !is_jumped
	if is_jump:
		is_jumped = true
	return is_jump
	
func get_jump_velocity():
	return JUMP_VELOCITY
	
func set_jump_velocity_last(jump_velocity):
	last_velocity = jump_velocity

func set_default_action():
	direction = [0, 0]
	action = [action[1], JUMP_NONE]
	
func is_landed(velocity_y):
	return velocity_y == 0 and last_velocity != 0

func get_jump_velocity_attack():
	return JUMP_VELOCITY / 2.0

func get_jump_velocity_knockback():
	return JUMP_VELOCITY / 1.5


#animation
func get_animation(animation_state):
	return animation_state
	

#state
func toggle_playable():
	if state == State.STATE_PLAYABLE:
		state = State.STATE_NOT_PLAYABLE
	else:
		state = State.STATE_PLAYABLE

func is_not_playable():
	return state == State.STATE_NOT_PLAYABLE
	
func is_playable():
	return state == State.STATE_PLAYABLE
	
func is_dead():
	return _current_state[1] == DEAD
	
func set_animation_scene_state():
	state = State.STATE_ANIMATION_SCENE

func is_animation_scene_state():
	return state == State.STATE_ANIMATION_SCENE
	
func set_playable(is_playable):
	if is_playable:
		state = State.STATE_PLAYABLE
	else:
		state = State.STATE_NOT_PLAYABLE


#direction
func get_x_velocity(velocity_x):
	var x = 0
	if direction[1]:
		if is_direction_changed():
			_speed = STEP
			direction[0] = direction[1]
		elif _speed + STEP >= SPEED:
			_speed = SPEED
		else:
			_speed += STEP
			
		x = direction[1] * _speed
	else:
		if _speed - STEP <= 0:
			_speed = 0
			x = move_toward(velocity_x, 0, SPEED)
		else:
			_speed -= STEP
			x = direction[0] * _speed
	
	return x
	
func is_max_speed():
	return abs(_speed) == SPEED
	
func set_speed_default():
	_speed = 0

func is_direction_changed():
	return direction[0] != direction[1]
	
func _init_states(states):
	_current_state = states
	
func set_attack(is_attack = true):
	_is_attack = is_attack
	is_attack = false
	
func is_state():
	return _current_state
