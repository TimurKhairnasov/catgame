extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_not_destroyed = true

func destroy():
	$AnimatedSprite2D.play("blow")
	await get_tree().create_timer(.5).timeout
	is_not_destroyed = true
	$AnimatedSprite2D.play("idle")
	self.visible = false


func _on_area_entered(body):
	if is_not_destroyed:
		is_not_destroyed = false
		destroy()
