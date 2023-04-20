extends Node

const PLAYER_HP = 5
var player_hp = PLAYER_HP
var player_skin = 0

func set_skin(skin: int):
	player_skin = skin
	
func get_skin():
	return player_skin
	
func change_hp(new_hp):
	player_hp = new_hp

func get_hp():
	return player_hp

func reset_hp():
	player_hp = PLAYER_HP
