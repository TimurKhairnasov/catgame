extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_main = $AnimatedSprite2D
@onready var animated_shield = $AnimatedShield
@onready var collision_shield = $CollisionShield
@onready var collision = $CollisionShape2D
@onready var blows = $blows
@onready var blows_burn = $blows/Burn
@onready var blow1 = $blows/Blow1
@onready var blow2 = $blows/Blow2
@onready var blow3 = $blows/Blow3
@onready var blow4 = $blows/Blow4

@onready var sound_alert = $soundEffects/Alert
@onready var sound_blow = $soundEffects/Blow
@onready var sound_explision = $soundEffects/Explosion
@onready var sound_take_a_hit = $soundEffects/TakeAHit

var knockback_tween

signal hp_changed
signal start_animation

var hp = 15

enum STATE {
	SLEEP,
	UNPROTECTED,
	PROTECTED,
	HIT,
	DEAD
}

var state = STATE.SLEEP

func _ready():
	collision_shield.set_deferred("disabled", true)
	_play_animation(animated_shield, "dissapear")
	call_deferred("change_hp", hp)

func _process(delta):
	
	match state:
		STATE.UNPROTECTED:
			_unprotect()
		STATE.PROTECTED:
			_protect()
	pass

func _unprotect():
	_play_animation(animated_shield, "dissapear")
	collision_shield.set_deferred("disabled", true)
	
func _protect():
	_play_animation(animated_shield, "appear")
	collision_shield.set_deferred("disabled", false)

func _play_animation(animated_sprite, animation: String):
	if (animated_sprite.animation != animation):
		animated_sprite.play(animation)

func _on_shield_body_entered(body):
	pass # Replace with function body.
	
func flip(is_on):
	animated_main.flip_h = is_on

func toggle_shield(is_on):
	if is_on:
		state = STATE.PROTECTED
	else:
		state = STATE.UNPROTECTED
		
func prepare_to_die():
	sound_alert.play()
	for i in range(20):
		animate_hit()
		await get_tree().create_timer(.2).timeout

func animate_hit():
	if knockback_tween:
		knockback_tween.kill()
		
	modulate = Color(1, 0, 0, 1)
	knockback_tween = get_tree().create_tween()
	knockback_tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), .20)

func burn():
	blows.visible = true
	blows_burn.play("burn")
	sound_blow.play()
	
func die():
	_play_animation(animated_main, "dead")
	
func blow():
	sound_alert.stop()	
	collision.set_deferred("disabled", true)
	collision_shield.set_deferred("disabled", true)
	blow1.play("blow")
	sound_explision.play()
	await get_tree().create_timer(.1).timeout
	blow2.play("blow")
	sound_explision.pitch_scale = 1.3
	sound_explision.play()
	await get_tree().create_timer(.1).timeout
	blow3.play("blow")
	sound_explision.pitch_scale = 0.7
	sound_explision.play()
	await get_tree().create_timer(.1).timeout
	blow4.play("blow")
	sound_explision.pitch_scale = 1
	sound_explision.play()
	animated_main.set_deferred("visible", false)
	
func change_hp(hp):
	emit_signal("hp_changed", hp)

func take_a_hit_boss():
	if state == STATE.PROTECTED:
		return
	collision.set_deferred("disabled", true)
	modulate = Color(1, 0, 0, 1)
	sound_take_a_hit.play()
	
	hp -= 1
	emit_signal("hp_changed", hp)
	
	knockback_tween = get_tree().create_tween()
	knockback_tween.parallel().tween_property(self, "modulate", Color(1, 1, 1, 1), .20)
	knockback_tween.parallel().tween_property(collision, "disabled", false, 1.2)
	
	if state == STATE.SLEEP:
		emit_signal("start_animation")
		await get_tree().create_timer(1.2).timeout
		return
