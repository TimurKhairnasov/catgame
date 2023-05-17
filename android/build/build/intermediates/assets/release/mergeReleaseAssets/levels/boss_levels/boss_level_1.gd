extends Node2D

const ATTACK_TRESHOLD = 3
const ATTACK_START_TRESHOLD = 1
const INTRO = 5

const ATTACK_HORIZONTAL_LEFT_HIGH = 1
const ATTACK_HORIZONTAL_LEFT_LOW = 2
const ATTACK_HORIZONTAL_LEFT_MEDIUM = 2.5
const ATTACK_HORIZONTAL_LEFT_SPREY_1 = 3
const ATTACK_HORIZONTAL_LEFT_SPREY_2 = 4
const ATTACK_HORIZONTAL_LEFT_SPREY_3 = 5
const ATTACK_HORIZONTAL_LEFT_SPREY_4 = 6
const ATTACK_HORIZONTAL_LEFT_SPREY_5 = 7
const ATTACK_HORIZONTAL_LEFT_SPREY_6 = 8
const ATTACK_HORIZONTAL_LEFT_SPREY_7 = 9
const ATTACK_HORIZONTAL_LEFT_SPREY_8 = 10
const ATTACK_HORIZONTAL_RIGHT_SPREY_1 = 11
const ATTACK_HORIZONTAL_RIGHT_SPREY_2 = 12
const ATTACK_HORIZONTAL_RIGHT_SPREY_3 = 13
const ATTACK_HORIZONTAL_RIGHT_SPREY_4 = 14
const ATTACK_HORIZONTAL_RIGHT_SPREY_5 = 15
const ATTACK_HORIZONTAL_RIGHT_SPREY_6 = 16
const ATTACK_HORIZONTAL_RIGHT_SPREY_7 = 17
const ATTACK_HORIZONTAL_RIGHT_SPREY_8 = 18

var _idle_count = 0
var attack_index = 0

const ATTACKS = [
	"attack_horizontal_left",
	"attack_sprey_right",
	"bomb_attack",
	"attack_horizontal_left",
	"attack_sprey_left",
	"bomb_attack"
]

var attack_set = ATTACKS
@onready var _animation_tree = $AnimationTree
@onready var intro_outro_player = $IntroOutroPlayer
@onready var outro_player = $OutroPlayer
@onready var spectator = $Spectator
@onready var player = $Player
@onready var music_intro = $music/Intro
@onready var music_boss = $music/BossMusic
@onready var music_boss_defeated = $music/BossDefeatedMusic

@onready var attack_horizontal_high = $attacksHorizontalLeft/AttackHigh
@onready var attack_horizontal_low = $attacksHorizontalLeft/AttackLow
@onready var attack_horizontal_medium = $attacksHorizontalLeft/AttackMedium
@onready var attack_sprey_left_1 = $attacksSpreyLeft/Attack1
@onready var attack_sprey_left_2 = $attacksSpreyLeft/Attack2
@onready var attack_sprey_left_3 = $attacksSpreyLeft/Attack3
@onready var attack_sprey_left_4 = $attacksSpreyLeft/Attack4
@onready var attack_sprey_left_5 = $attacksSpreyLeft/Attack5
@onready var attack_sprey_left_6 = $attacksSpreyLeft/Attack6
@onready var attack_sprey_left_7 = $attacksSpreyLeft/Attack7
@onready var attack_sprey_left_8 = $attacksSpreyLeft/Attack8
@onready var attack_sprey_right_1 = $attacksSpreyRight/Attack1
@onready var attack_sprey_right_2 = $attacksSpreyRight/Attack2
@onready var attack_sprey_right_3 = $attacksSpreyRight/Attack3
@onready var attack_sprey_right_4 = $attacksSpreyRight/Attack4
@onready var attack_sprey_right_5 = $attacksSpreyRight/Attack5
@onready var attack_sprey_right_6 = $attacksSpreyRight/Attack6
@onready var attack_sprey_right_7 = $attacksSpreyRight/Attack7
@onready var attack_sprey_right_8 = $attacksSpreyRight/Attack8

@onready var boss_health = $UI/BossHealth
@onready var sound_drone_flying = $soundEffects/DroneFlying
@onready var mobile_controls = $mobile_controls

@onready var sound_monster_appear = $soundEffects/MonsterAppear
@onready var sound_panic = $soundEffects/Panic
@onready var sound_monster_attack = $soundEffects/MonsterAttack
@onready var sound_slap = $soundEffects/Slap

@onready var camera = $Player/Camera2D
 
func _ready():
	intro_outro_player.play("intro")
	spectator.set_animated_state()
	music_intro.play()

var start_index = 0
var treshold = ATTACK_START_TRESHOLD
func increace_idle_count():
	_idle_count += 1

	if start_index < INTRO:
		treshold = ATTACK_START_TRESHOLD
	else:
		treshold = ATTACK_TRESHOLD
	
	if _idle_count%treshold == 0:
		attack()
		
	start_index += 1
		
func attack():
	var position = attack_index%6
	var attack = attack_set[position]
	_animation_tree.set_condition(attack, true)
	attack_index += 1
	
func die():
	music_boss.stop()
	music_boss_defeated.play()
	_animation_tree.set_condition("die", true)
	
func shoot(attack):
	match attack:
		ATTACK_HORIZONTAL_LEFT_HIGH:
			attack_horizontal_high.shoot()
		ATTACK_HORIZONTAL_LEFT_LOW:
			attack_horizontal_low.shoot()
		ATTACK_HORIZONTAL_LEFT_MEDIUM:
			attack_horizontal_medium.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_1:
			attack_sprey_left_1.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_2:
			attack_sprey_left_2.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_3:
			attack_sprey_left_3.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_4:
			attack_sprey_left_4.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_5:
			attack_sprey_left_5.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_6:
			attack_sprey_left_6.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_7:
			attack_sprey_left_7.shoot()
		ATTACK_HORIZONTAL_LEFT_SPREY_8:
			attack_sprey_left_8.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_1:
			attack_sprey_right_1.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_2:
			attack_sprey_right_2.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_3:
			attack_sprey_right_3.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_4:
			attack_sprey_right_4.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_5:
			attack_sprey_right_5.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_6:
			attack_sprey_right_6.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_7:
			attack_sprey_right_7.shoot()
		ATTACK_HORIZONTAL_RIGHT_SPREY_8:
			attack_sprey_right_8.shoot()

func _on_boss_hp_changed(hp):
	if !_animation_tree.active:
		return
	if hp > 0:
		_idle_count += ((ATTACK_TRESHOLD - _idle_count%ATTACK_TRESHOLD) - 1)
		if hp < 5:
			treshold = ATTACK_START_TRESHOLD
	else:
		die()

func _start_animation():
	music_intro.stop()
	if !music_boss.playing:
		music_boss.play()
	boss_health.visible = true
	_animation_tree.active = true
	sound_drone_flying.play()

func _on_area_start_outro_body_entered(body):
	mobile_controls.hide_buttons()
	player.set_animation_scene_state()
	outro_player.play("start")
	
const START_LINES = [
	"I see you've made through\nthe portal in one piece!\nThat's a relief.",
	"These portals seem to be\nrather random with their destinations.",
	"Tell me, have you learned\nany new tricks since entering\nthat portal? The ability to breathe\nfire, or summon laser beams from\nyour eyes?",
	"...",
	"Not even a smirk? You have\nno sense of humor, pal...",
	"Anyway, you might wonder\nwho am I, and why I have\nsuch beautiful eye...",
]
const START_LINES_RUS = [
	"Я вижу, что ты преодолел\nпортал целым и невредимым!\nЭто облегчение.",
	"Эти порталы кажутся\nдовольно случайными\nсо своими пунктами назначения.",
	"Скажи, научился ли ты\nкаким-нибудь новым трюкам после входа\nв портал? Способность дышать\nстрелять или вызывать\nиз глаз лазерные лучи?",
	"...",
	"Даже ухмылки? У тебя нет\nнет чувства юмора, приятель...",
	"В любом случае, вам может\nбыть интересно, кто я и\nпочему у меня такой красивый глаз...",
]
const TURN_LINE = "The thing is that I am"
const TURN_LINE_RUS = "Дело в том, что я"
const TIME_TO_READ = 2
func start_spectator_line():
	music_boss_defeated.volume_db = -15
	for i in range(START_LINES_RUS.size()):
		var duration = spectator.set_line_text(START_LINES_RUS[i])
		await get_tree().create_timer(duration + TIME_TO_READ).timeout 
	outro_player.play("explosion")
	var duration = spectator.set_line_text(TURN_LINE_RUS)
	await get_tree().create_timer(duration + 1).timeout 
	spectator.set_line_text("")
	
var rng = RandomNumberGenerator.new()
var shake_amount = 2.0
func shake_camera():
	music_boss_defeated.stop()
	for i in range(10):
		camera.set_offset(Vector2(
			rng.randi_range(-1.0, 1.0) * shake_amount,
			rng.randi_range(-1.0, 1.0) * shake_amount
		))
		await get_tree().create_timer(0.05).timeout
	camera.set_offset(Vector2(0, 0))

func start_camera_animation():
	outro_player.play("camera_anim")
	
func start_monster_attack_animation():
	outro_player.play("attack")
	
func start_outro_cam_animation():
	outro_player.play("outro_cam_anim")
	
const END_LINES = [
	"HOLLY SHIT!",
	"That's unusial for your world,\nisn't it?"
]
const END_LINES_RUS = [
	"Срань господня!",
	"Это необычно для вашего мира,\nправда?"
]
func end_level():
	for i in range(END_LINES_RUS.size()):
		if i == 1:
			spectator.flip()
		var duration = spectator.set_line_text(END_LINES_RUS[i])
		await get_tree().create_timer(duration + TIME_TO_READ).timeout 
	spectator.set_line_text("")
	outro_player.play("outro")
	music_intro.play()
	
func real_end_leve():
	music_intro.stop()
	Global.go_to_next_level()
	
func play_sound(sound):
	match sound:
		1:
			sound_monster_appear.play()
			sound_panic.play()
		2:
			sound_monster_attack.play()
		3:
			sound_slap.play()
