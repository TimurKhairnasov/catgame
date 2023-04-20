extends CharacterBody2D

const _player_state = preload("res://player/player_state.gd")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal hp_changed
signal dead

@onready var animated_sprite = $AnimatedSpriteSand
@onready var ememy_contact_area = $EnemyContactArea/CollisionShape2D
@onready var label_switch = $changeSkin/SwitchLabel

@onready var sound_jump = $soundEffects/jump
@onready var sound_land = $soundEffects/land
@onready var sound_damage = $soundEffects/damage
@onready var sound_death = $soundEffects/death
@onready var sound_heal = $soundEffects/heal

@onready var sprite_sand = $AnimatedSpriteSand
@onready var sprite_dark_grey = $AnimatedSpriteDarkGrey
@onready var sprite_orange = $AnimatedSpriteOrange
@onready var sprite_grey = $AnimatedSpriteGrey
@onready var sprite_black = $AnimatedSpriteBlack

var hp = 0

var state := _player_state.new()

var knockback: Vector2 = Vector2(0, 0)
var knockback_tween

var is_hit = false
var _is_attack = false

var skin_variant = 0
var is_in_switch_state = null

func _ready():
	set_skin_variant(GlobalPlayerState.get_skin())
	call_deferred("change_hp", GlobalPlayerState.get_hp())
	
func _process(delta):
	
	if knockback != Vector2(0, 0): # knockback after getting hit
		_knockback()
		return
	
	var direction
	var is_jump_pressed
	var is_jump_released
	
	if is_in_switch_state and Input.is_action_just_pressed("ui_accept"):
		state.toggle_playable()
		if state.is_playable():
			GlobalPlayerState.set_skin(skin_variant)
	
	if hp > 0 and state.is_playable():
		state.set_action(
			Input.get_axis("ui_left", "ui_right"),
			Input.is_action_just_pressed("ui_accept"),
			Input.is_action_just_released("ui_accept")
		)
	else:
		state.set_default_action()
#
	var animation_state = state.IDLE
	if state.is_animation_scene_state():
		return
	elif state.is_not_playable():
		animation_state = state.IDLE_LIE_DOWN
	elif hp == 0:
		animation_state = state.DEAD
	elif _is_attack:
		animation_state = state.ATTACK
	elif not is_on_floor() and velocity.y <= 0:
		animation_state = state.JUMP
	elif not is_on_floor():
		animation_state = state.FALL
	elif velocity.x == 0:
		animation_state = state.IDLE
	elif state.is_max_speed():
		animation_state = state.RUN
	else:
		animation_state = state.WALK

	_flip()
	_play_animation(animation_state)
	_move(delta, state)

func _knockback():
	state.set_speed_default()
	velocity += knockback
	move_and_slide()
	
func _flip():
	if (velocity.x > 0):
		animated_sprite.flip_h = false
	elif (velocity.x < 0):
		animated_sprite.flip_h = true
	
func _move(delta, state : PlayerState):
	
	#gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#jump
	if state.is_jump(is_on_floor()):
		sound_jump.play()
		velocity.y = state.get_jump_velocity()
	state.set_jump_velocity_last(velocity.y)
	
	#sounds
	if state.is_landed(velocity.y):
		sound_land.play()
	
	#direction
	velocity.x = state.get_x_velocity(velocity.x)
	
	move_and_slide()
	
func _play_animation(animation_state: String):
	var animation = state.get_animation(animation_state)
	if animated_sprite.animation != animation:
		animated_sprite.play(animation)

func _on_enemy_contact(enemy: Node2D):
	if position.y < enemy.position.y:
		hit_enemy(enemy)
	
func hit_enemy(enemy: Node2D):
	if enemy.has_method("take_a_hit"):
		take_heal(1)
		enemy.take_a_hit()
	if enemy.has_method("take_a_hit_boss"):
		enemy.take_a_hit_boss()
	velocity.y = state.get_jump_velocity_attack()
	
func take_damage(damage, knockback_vector = Vector2(70, 0), duration = 0.20):
	print("state.is_invinsible=", state.is_invinsible, "state.is_dead()=", state.is_dead())
	if state.is_invinsible or state.is_dead():
		return
	state.is_invinsible = true
	sound_damage.play()
	change_hp(-damage)
	
	if knockback_tween:
		knockback_tween.kill()
	
	knockback = knockback_vector
	knockback_tween = get_tree().create_tween()
	knockback_tween.parallel().tween_property(self, "knockback", Vector2(0, 0), duration)
	modulate = Color(1, 0, 0, 1)
	ememy_contact_area.set_deferred("disabled", true)
	knockback_tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), duration)
	knockback_tween.parallel().tween_property(ememy_contact_area, "disabled", false, duration)
	knockback_tween.parallel().tween_property(state, "is_invinsible", false, 1)
	velocity.y = state.get_jump_velocity_knockback()
	return hp

func die():
	if state.is_dead():
		return
	sound_death.play()
	await get_tree().create_timer(1).timeout
	emit_signal("dead")
	
func take_heal(heal, duration = 0.20):
	sound_heal.play()
	_is_attack = true
	change_hp(heal)
	if knockback_tween:
		knockback_tween.kill()
		
	modulate = Color(0, 1, 0, 1)
	knockback_tween = get_tree().create_tween()
	knockback_tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), duration)
	knockback_tween.parallel().tween_property(self, "_is_attack", false, 0.50)
	
func change_hp(diff: int):
	if hp + diff > GlobalPlayerState.PLAYER_HP:
		hp = GlobalPlayerState.PLAYER_HP
	elif hp + diff <= 0:
		hp = 0
		die()
	else:
		hp += diff
	GlobalPlayerState.change_hp(hp)
	emit_signal("hp_changed", hp)

func update_hp():
	pass # Replace with function body.

func _on_change_skin(body):
	if state.is_animation_scene_state() or body == self:
		return
	is_in_switch_state = true
	if state.is_not_playable():
		label_switch.visible = true

func _on_change_skin_exited(body):
	is_in_switch_state = false
	label_switch.visible = false
	
	
#external
func set_playable(is_playable):
	if state.is_animation_scene_state():
		is_in_switch_state = null
	state.set_playable(is_playable)
		
func set_animation_scene_state():
	state.set_animation_scene_state()
	
func set_skin_variant(variant):
	self.skin_variant = variant
	animated_sprite.visible = false
	match variant:
		0:
			animated_sprite = sprite_sand
		1:
			animated_sprite = sprite_dark_grey
		2:
			animated_sprite = sprite_orange
		3:
			animated_sprite = sprite_grey
		4:
			animated_sprite = sprite_black
	animated_sprite.visible = true
	
func flip():
	animated_sprite.flip_h = !animated_sprite.flip_h	

func _on_peakes_damage(body):
	take_damage(1)
