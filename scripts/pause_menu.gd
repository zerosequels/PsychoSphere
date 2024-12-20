extends Control

@onready var resume_bttn = $PanelContainer/MarginContainer/VBoxContainer/resume_bttn
@onready var restart_bttn = $PanelContainer/MarginContainer/VBoxContainer/restart_bttn
@onready var quit_bttn = $PanelContainer/MarginContainer/VBoxContainer/quit_bttn
@onready var game_over_label = $PanelContainer/MarginContainer/VBoxContainer/game_over_label


@onready var master_volume = $PanelContainer/options_container/VBoxContainer/volume_slider/MarginContainer/master_volume_slider
@onready var music_volume = $PanelContainer/options_container/VBoxContainer/volume_slider_music/MarginContainer/music_volume_slider
@onready var sfx_volume = $PanelContainer/options_container/VBoxContainer/volume_slider_sfx/MarginContainer/sfx_volume_slider

var restart_game_warning = false

func _ready():
	
	$PanelContainer/options_container/VBoxContainer/shader_resolution_warning.visible = false
	master_volume.value = PlayerData.master_volume_value
	music_volume.value = PlayerData.music_volume_value
	sfx_volume.value = PlayerData.sfx_volume_value
	
	resume_bttn.disabled = true
	restart_bttn.disabled = true
	quit_bttn.disabled = true
	$PanelContainer/MarginContainer/VBoxContainer/start_menu_bttn.disabled = true
	$PanelContainer/MarginContainer/VBoxContainer/options_bttn.disabled = true
	$AnimationPlayer.play("RESET")
	

func _process(delta):
	detect_escape_key_pressed()
	
func fade_out_menu():
	$fade_screen.fade_out()
	
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	resume_bttn.disabled = true
	restart_bttn.disabled = true
	quit_bttn.disabled = true
	$PanelContainer/MarginContainer/VBoxContainer/start_menu_bttn.disabled = true
	$PanelContainer/MarginContainer/VBoxContainer/options_bttn.disabled = true
	game_over_label.visible = false
	
func pause():
	resume_bttn.disabled = false
	restart_bttn.disabled = false
	quit_bttn.disabled = false
	$PanelContainer/MarginContainer/VBoxContainer/start_menu_bttn.disabled = false
	$PanelContainer/MarginContainer/VBoxContainer/options_bttn.disabled = false
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	game_over_label.visible = false

func game_over_pause():
	resume_bttn.disabled = true
	resume_bttn.visible = false
	restart_bttn.disabled = false
	quit_bttn.disabled = false
	$PanelContainer/MarginContainer/VBoxContainer/start_menu_bttn.disabled = false
	$PanelContainer/MarginContainer/VBoxContainer/options_bttn.disabled = false
	game_over_label.visible = true
	game_over_label.text = "GAME OVER"
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func victory_pause():
	resume_bttn.disabled = true
	resume_bttn.visible = false
	restart_bttn.disabled = false
	quit_bttn.disabled = false
	$PanelContainer/MarginContainer/VBoxContainer/start_menu_bttn.disabled = false
	$PanelContainer/MarginContainer/VBoxContainer/options_bttn.disabled = false
	game_over_label.visible = true
	game_over_label.text = "YOU WIN"
	get_tree().paused = true
	$AnimationPlayer.play("blur")
		
func detect_escape_key_pressed():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()

func activate_game_over_menu():
	if get_tree().paused == true:
		resume()
	game_over_pause()

func activate_victory_menu():
	if get_tree().paused == true:
		resume()
	victory_pause()

func restart():
	WaveData.reset_game_data()
	TowerAndBoonData.reset_tower_and_boon_data()
	$fade_screen.fade_in()
	
	
func quit():
	get_tree().quit()
	
func _on_resume_bttn_pressed():
	resume()


func _on_restart_bttn_pressed():
	resume()
	restart()


func _on_quit_bttn_pressed():
	GlobalAudio.play_quit()
	await get_tree().create_timer(2.0).timeout
	quit()


func _on_start_menu_bttn_pressed():
	if get_tree().paused == true:
		GlobalAudio.stop_main_theme()
		get_tree().change_scene_to_file("res://scenes/laboratory.tscn")


func _on_options_bttn_pressed():
	$PanelContainer/MarginContainer.visible = false
	$PanelContainer/options_container.visible = true
	$PanelContainer/options_container/VBoxContainer/shader_resolution_dropdown2/MarginContainer/OptionButton.select(PlayerData.shader_option_index)
	$PanelContainer/options_container/VBoxContainer/resolution_dropdown/MarginContainer/OptionButton.select(PlayerData.resolution_index)


func _on_back_bttn_pressed():
	$PanelContainer/MarginContainer.visible = true
	$PanelContainer/options_container.visible = false


func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(0,linear_to_db(value))
	


func _on_music_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"),linear_to_db(value))


func _on_sfx_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("grungle"),linear_to_db(value))
	



func _on_volume_slider_drag_ended(value_changed):
	PlayerData.master_volume_value = master_volume.value
	PlayerData.music_volume_value = music_volume.value
	PlayerData.sfx_volume_value = sfx_volume.value
	PlayerData.save_to_config()


func _on_resolution_item_selected(index):
	match index:
		0:
			PlayerData.resolution_index = 0
			PlayerData.update_resolution(1280,720)
			
		1:
			PlayerData.resolution_index = 1
			PlayerData.update_resolution(1600,900)
			
		2:
			PlayerData.resolution_index = 2
			PlayerData.update_resolution(1920,1080)
			
		3:
			PlayerData.resolution_index = 3
			PlayerData.update_resolution(3840,2400)
	


func _on_shader_item_selected(index):
	match index:
		0:
			PlayerData.background_plexus_resolution_x = 200
			PlayerData.background_plexus_resolution_y = 100
			PlayerData.background_shader_octave = 5
		1:
			PlayerData.background_plexus_resolution_x = 400
			PlayerData.background_plexus_resolution_y = 300
			PlayerData.background_shader_octave = 10
		2:
			PlayerData.background_plexus_resolution_x = 600
			PlayerData.background_plexus_resolution_y = 400
			PlayerData.background_shader_octave = 20
		3:
			PlayerData.background_plexus_resolution_x = 800
			PlayerData.background_plexus_resolution_y = 500
			PlayerData.background_shader_octave = 30
	PlayerData.shader_option_index = index
	restart_game_warning = true
	$PanelContainer/options_container/VBoxContainer/shader_resolution_warning.visible = true
	PlayerData.save_to_config()
