extends Node

signal update_game_speed(game_speed)

var global_game_speed = 1.0

func set_global_game_speed(new_speed):
	global_game_speed = new_speed
	GlobalAudio.speed_change_sfx()
	emit_signal("update_game_speed",global_game_speed)

func get_global_game_speed():
	return global_game_speed
