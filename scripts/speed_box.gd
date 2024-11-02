extends NinePatchRect

@onready var play_bttn = $play_bttn
@onready var pause_bttn = $pause_bttn
@onready var speed_up_bttn = $speed_up_bttn
@onready var super_speed_up_bttn = $super_speed_up_bttn


var is_pause = false
var is_play = true
var speed_up = false
var super_speed_up = false

var target_game_speed = 1.0


func _on_pause_bttn_toggled(toggled_on):
	if toggled_on:
		play_bttn.button_pressed = false
		speed_up_bttn.button_pressed= false
		super_speed_up_bttn.button_pressed = false

		target_game_speed = 0.0
		GameMode.set_global_game_speed(target_game_speed)


func _on_play_bttn_toggled(toggled_on):
	if toggled_on:
		speed_up_bttn.toggle_mode = false
		pause_bttn.toggle_mode = false
		super_speed_up_bttn.toggle_mode = false
		speed_up_bttn.toggle_mode = true
		pause_bttn.toggle_mode = true
		super_speed_up_bttn.toggle_mode = true
		target_game_speed = 0.25
		GameMode.set_global_game_speed(target_game_speed)


func _on_speed_up_bttn_toggled(toggled_on):
	if toggled_on:
		play_bttn.toggle_mode = false
		pause_bttn.toggle_mode = false
		super_speed_up_bttn.toggle_mode = false
		play_bttn.toggle_mode = true
		pause_bttn.toggle_mode = true
		super_speed_up_bttn.toggle_mode = true
		target_game_speed = 1.0
		GameMode.set_global_game_speed(target_game_speed)


func _on_super_speed_up_bttn_toggled(toggled_on):
	if toggled_on:
		play_bttn.toggle_mode = false
		speed_up_bttn.toggle_mode = false
		pause_bttn.toggle_mode = false
		play_bttn.toggle_mode = true
		speed_up_bttn.toggle_mode = true
		pause_bttn.toggle_mode = true
		target_game_speed = 1.5
		GameMode.set_global_game_speed(target_game_speed)
