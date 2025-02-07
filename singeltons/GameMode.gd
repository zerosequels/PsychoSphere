extends Node

signal update_game_speed(game_speed)

var global_game_speed = 1.0
var default_game_speed = 1.0
var just_started = true
var fresh_start = true

func set_global_game_speed(new_speed):
	global_game_speed = new_speed
	GlobalAudio.speed_change_sfx()
	emit_signal("update_game_speed",global_game_speed)

func get_global_game_speed():
	return global_game_speed

func reset_global_game_speed():
	set_global_game_speed(default_game_speed)

func get_is_first_ready():
	var did_just_start = fresh_start
	fresh_start = false
	return did_just_start
	
