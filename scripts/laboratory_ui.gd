extends Control

signal astral_projection_begin
@onready var distortion_layer:Sprite2D = $distortion_layer

@onready var master_volume = $MarginContainer/options/volume_slider/MarginContainer/master_volume_slider
@onready var music_volume = $MarginContainer/options/music_volume_slider/MarginContainer/music_volume_slider
@onready var sfx_volume = $MarginContainer/options/sfx_volume_slider/MarginContainer/sfx_volume_slider

func _process(delta):
	if Input.is_action_just_released("reset_display_shortcut"):
		$MarginContainer/options/shader_resolution_dropdown2/MarginContainer/OptionButton.select(2)
		$MarginContainer/options/resolution_dropdown/MarginContainer/OptionButton.select(2)
		_on_resolution_button_item_selected(2)
		_on_shader_option_item_selected(2)

func _on_play_button_pressed():
	emit_signal("astral_projection_begin")
	increase_ui_distortion()

func _on_upgrade_button_pressed():
	pass # Replace with function body.
func _on_options_button_pressed():
	master_volume.value = PlayerData.master_volume_value
	music_volume.value = PlayerData.music_volume_value
	sfx_volume.value = PlayerData.sfx_volume_value
	
	$MarginContainer/options/resolution_dropdown/MarginContainer/OptionButton.select(PlayerData.resolution_index)
	$MarginContainer/options/shader_resolution_dropdown2/MarginContainer/OptionButton.select(PlayerData.shader_option_index)
	
	
	$MarginContainer/VBoxContainer/play_button.disabled = true
	$MarginContainer/VBoxContainer/upgrade_button.disabled = true
	$MarginContainer/VBoxContainer/options_button.disabled = true
	$MarginContainer/VBoxContainer/credits_button.disabled = true
	$MarginContainer/VBoxContainer/quit_button.disabled = true
	
	$MarginContainer/options.visible = true
	$MarginContainer/VBoxContainer.visible = false

func _on_quit_button_pressed():
	get_tree().quit()
	
func increase_ui_distortion():
	distortion_layer.trigger_distortion()

func _on_credits_button_button_up():
	get_tree().change_scene_to_file("res://scenes/credits_screen.tscn")

func _on_back_button_pressed():
	$MarginContainer/VBoxContainer/play_button.disabled = false
	$MarginContainer/VBoxContainer/upgrade_button.disabled = false
	$MarginContainer/VBoxContainer/options_button.disabled = false
	$MarginContainer/VBoxContainer/credits_button.disabled = false
	$MarginContainer/VBoxContainer/quit_button.disabled = false
	
	$MarginContainer/options.visible = false
	$MarginContainer/VBoxContainer.visible = true


func _on_master_volume_slider_value_changed(value):
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

func _on_resolution_button_item_selected(index):
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
			


func _on_shader_option_item_selected(index):
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
	PlayerData.save_to_config()
