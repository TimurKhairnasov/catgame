extends Node2D

@onready var mobile_controls = $mobile_controls
@onready var animation_tree = $AnimationTree
@onready var player = $Player
@onready var player_2 = $Player2
@onready var player_3 = $Player3
@onready var player_4 = $Player4
@onready var player_5 = $Player5

@onready var music_level_intro = $music/level_intro
@onready var music_intro = $music/intro

@onready var outro_player = $OutroPlayer
@onready var camera = $Camera2D
@onready var sound_explosion = $ExplosionSound

# Called when the node enters the scene tree for the first time.
func _ready():
	mobile_controls.hide_buttons()
	animation_tree.active = true
	player.set_animation_scene_state()
	player.set_skin_variant(0)

	player_2.set_animation_scene_state()
	player_2.set_skin_variant(1)
	player_2.flip()

	player_3.set_animation_scene_state()
	player_3.set_skin_variant(4)

	player_4.set_animation_scene_state()
	player_4.set_skin_variant(3)

	player_5.set_animation_scene_state()
	player_5.set_skin_variant(2)
	
func _animation_into_ended():
	mobile_controls.show_buttons()
	animation_tree.active = false
	player.set_playable(true)
	player_2.set_playable(false)
	player_3.set_playable(false)
	player_4.set_playable(false)
	player_5.set_playable(false)
	music_level_intro.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_end_level(body):
	outro_player.play("outro")
	await get_tree().create_timer(1).timeout
	music_level_intro.stop()
	Global.go_to_next_level()
	
func start_next_scene():
	animation_tree.set_condition("intro", true)

var rng = RandomNumberGenerator.new()
var shake_amount = 2.0
func shake_camera():
	music_intro.stop()
	sound_explosion.play()
	for i in range(10):
		camera.set_offset(Vector2(
			rng.randi_range(-1.0, 1.0) * shake_amount,
			rng.randi_range(-1.0, 1.0) * shake_amount
		))
		await get_tree().create_timer(0.05).timeout
	camera.set_offset(Vector2(0, 0))
