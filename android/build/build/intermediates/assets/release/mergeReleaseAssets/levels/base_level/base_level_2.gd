extends Node2D

@onready var spectator = $Spectator
@onready var intro_outro_player = $IntroOutroPlayer
@onready var music = $music
@onready var animation_player = $AnimationPlayer
@onready var player = $Player
@onready var mobile_controls = $mobile_controls
@onready var spectator_script_starter = $SpectatorScriptStarter/CollisionShape2

# Called when the node enters the scene tree for the first time.
func _ready():
	spectator.set_animated_state()
	intro_outro_player.play("intro")
	music.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
const GREETINGS_LINES = [
	"!",
	"¡ɐʇuouɐɹɐʇ ɐɯ ɐsᴉɐ",
	"A-ha!",
	"Streaming directly into your\nmind should work. Yes...\nI see the resonance, the lines\nof connection.",
	"You are a feline, it seems.\nYet, you possess more than\nmere instincts. Perhaps there\nis something you can offer me.",
	"I have recently arrived here,\nand I must admit that I am\nstill struggling to understand\nthis world.",
	"Despite being smart, I simply\ncannot grasp many of your\nworld's concepts.",
	"But I know why I am here. I am\nsearching for a catalyst",
	"Something bad is coming...",
	"We are in a city, right? And\nthere are people living here,\ngoing about their lives.",
	"If you help me, they and\neveryone else in this world\nsurvive.",
	"It is still difficult to describe\nwhat it is that I need.\nIt is beyond your reality,\nbeyond your experience.",
	"But I believe you can still\nbe useful to me.",
	"...",
	"Hello! I know you understand me,\nnod or something!",
	"...",
	"Nevermind...We need to move.\nTime is of the essence..."
]

const PLAYTIME_LINES = [
	"You know, I must say that\nI find your world rather fascinating.\nWhat with all the random portals?",
	"Why don't cats play poker\nin the jungle? Too many cheetah!",
	"Yeap, no reaction...\nNot surprised!",
	"You know, these portals\nfascinate me...",
	"I must say, humans are\na curious species. But what is\nthe obsession with cheeseburgers?",
	"I think we must find an\nopen portal.",
	"Thanks for asking, but\nI don't need eye drops...",
	"It's exhausting to fly\naround through the walls,\nyou know.",
	"Are we there yet?"
]

func text_line(text):
	var duration = spectator.set_line_text(text)
	await get_tree().create_timer(duration + TIME_TO_READ).timeout 
	spectator.set_line_text("")

const TIME_TO_READ = 2
var line = 0
func start_line():
	for i in range(GREETINGS_LINES.size()):
			var duration = spectator.set_line_text(GREETINGS_LINES[i])
			await get_tree().create_timer(duration + TIME_TO_READ).timeout 
	spectator.set_line_text("")
	start_scene_animation("open_the_wall")

func _on_spectator_script_starter_body_entered(body):
	mobile_controls.hide_buttons()
	$SpectatorScriptStarter/CollisionShape2D.disabled = true
	music.volume_db = -15
	player.set_animation_scene_state()
	animation_player.play("spectator_meeting")

func deactivate_animation():
	mobile_controls.show_buttons()
	music.volume_db = 0
	player.set_playable(true)

const PLAYING_LINE_STEP = 5
var is_playing_line = false
func _on_spectator_on_peering():
	if is_playing_line:
		return
	line += 1
	if line%PLAYING_LINE_STEP != 0 or line/PLAYING_LINE_STEP > PLAYTIME_LINES.size():
		return 
	is_playing_line = true
	var duration = spectator.set_line_text(PLAYTIME_LINES[line/PLAYING_LINE_STEP-1])
	await get_tree().create_timer(duration + TIME_TO_READ).timeout 
	spectator.set_line_text("")
	is_playing_line = false

func _on_end_level_end_level():
	intro_outro_player.play("outro")
	await get_tree().create_timer(1).timeout
	music.stop()
	Global.go_to_next_level()
	
func start_scene_animation(animation):
	animation_player.play(animation)
