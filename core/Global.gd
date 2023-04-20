extends Node

var current_scene_ref: WeakRef
#var title_screen: Control
var show_pause_sceen = false

signal on_pause_state_change

var main = "res://main_screen.tscn"

@onready var levels = [
	"res://levels/movies/intro.tscn",
	"res://levels/levels/level_1.tscn",
	"res://levels/level1/level_1.tscn",
	"res://levels/base_level/base_level_2.tscn",
	"res://levels/boss_levels/boss_level_1.tscn",
	"res://levels/demo_end/demo_end.tscn"
]

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root = get_tree().get_root()
	var scene = root.get_child(root.get_child_count() - 1)
	current_scene_ref = weakref(scene)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		print("_process")
		toggle_pause()

var level = 0
func go_to_next_level():
	level += 1
	print(level)
	goto_scene(levels[level])

func restart():
	GlobalPlayerState.change_hp(GlobalPlayerState.PLAYER_HP)
	goto_scene(levels[level])
	
func goto_scene(scene_path: String):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	var scene = load(scene_path)
	call_deferred("_deferred_goto_scene", scene)
	
func go_to_main_menu():
	print("go_to_main_menu")
	if show_pause_sceen:
		toggle_pause()
	show_pause_sceen = false
	level = 0
	goto_scene(main)
 
func toggle_pause():
	print("toggle_pause")
	show_pause_sceen = !show_pause_sceen
#	if title_screen:
#		if show_pause_sceen:
#			title_screen.show()
#		else:
#			title_screen.hide()
	get_tree().paused = show_pause_sceen
	emit_signal("on_pause_state_change", show_pause_sceen)

func start_new_game():
	goto_scene(levels[0])

func goto_outro():
	pass
	
func exit_game():
	get_tree().quit()

func _deferred_goto_scene(scene: PackedScene):
	# It is now safe to remove the current scene
	var current_scene = current_scene_ref.get_ref()
	if current_scene:
		print("current_scene true")
		current_scene.free()

	# Instance the new scene.
	var new_scene = scene.instantiate()
	current_scene_ref = weakref(new_scene)

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(new_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(new_scene)

#func get_nav_path(point1, point2):
	#return nav.get_simple_path(point1, point2)
