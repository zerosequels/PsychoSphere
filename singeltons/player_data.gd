extends Node

signal update_background_plexus_settings

#audio settings
var master_volume_value = 1.0
var music_volume_value = 1.0
var sfx_volume_value = 1.0
#background plexus resolution
var background_plexus_resolution_x = 600
var background_plexus_resolution_y = 400
var background_shader_octave = 20
#viewport resolution
var viewport_resolution_x = 1920
var viewport_resolution_y = 1080

var resolution_index = 2
var shader_option_index = 2

var save_dict = {
		"master_volume_value": master_volume_value,
		"music_volume_value": music_volume_value,
		"sfx_volume_value": sfx_volume_value,
		"background_plexus_resolution_x": background_plexus_resolution_x,
		"background_plexus_resolution_y": background_plexus_resolution_y,
		"background_shader_octave": background_shader_octave,
		"viewport_resolution_x": viewport_resolution_x,
		"viewport_resolution_y": viewport_resolution_y,
		"resolution_index ": resolution_index,
		"shader_option_index": shader_option_index
		}

func populate_missing_values():
	if !save_dict.has("master_volume_value"):
		save_dict["master_volume_value"] = 1.0
	if !save_dict.has("music_volume_value"):
		save_dict["music_volume_value"] = 1.0
	if !save_dict.has("sfx_volume_value"):
		save_dict["sfx_volume_value"] = 1.0
	if !save_dict.has("background_plexus_resolution_x"):
		save_dict["background_plexus_resolution_x"] = 600
	if !save_dict.has("background_plexus_resolution_y"):
		save_dict["background_plexus_resolution_y"] = 400
	if !save_dict.has("background_shader_octave"):
		save_dict["background_shader_octave"] = 20
	if !save_dict.has("viewport_resolution_x"):
		save_dict["viewport_resolution_x"] = 1920
	if !save_dict.has("viewport_resolution_y"):
		save_dict["viewport_resolution_y"] = 1080
	if !save_dict.has("resolution_index"):
		save_dict["resolution_index"] = 2
	if !save_dict.has("shader_option_index"):
		save_dict["shader_option_index"] = 2

func create_new_save_file():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_game.store_line(json_string)
	save_game.close()

func save_to_config():
	save_dict = {
		"master_volume_value": master_volume_value,
		"music_volume_value": music_volume_value,
		"sfx_volume_value": sfx_volume_value,
		"background_plexus_resolution_x": background_plexus_resolution_x,
		"background_plexus_resolution_y": background_plexus_resolution_y,
		"background_shader_octave": background_shader_octave,
		"viewport_resolution_x": viewport_resolution_x,
		"viewport_resolution_y": viewport_resolution_y,
		"resolution_index": resolution_index,
		"shader_option_index": shader_option_index
		}
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_dict)
	save_game.store_line(json_string)
	save_game.close()
	

# Called when the node enters the scene tree for the first time.
func _ready():

	if FileAccess.file_exists("user://savegame.save"):
		var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_string = save_game.get_line()
		save_dict = JSON.parse_string(json_string)
		save_game.close()
		populate_missing_values()

	else:
		create_new_save_file()
		var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_string = save_game.get_line()
		save_dict = JSON.parse_string(json_string)
		save_game.close()
	
	master_volume_value = save_dict["master_volume_value"]
	music_volume_value = save_dict["music_volume_value"]
	sfx_volume_value = save_dict["sfx_volume_value"]
	
	background_plexus_resolution_x = save_dict["background_plexus_resolution_x"]
	background_plexus_resolution_y = save_dict["background_plexus_resolution_y"]
	background_shader_octave = save_dict["background_shader_octave"]
	
	viewport_resolution_x = save_dict["viewport_resolution_x"]
	viewport_resolution_y = save_dict["viewport_resolution_y"]
	
	resolution_index = save_dict["resolution_index"]
	shader_option_index = save_dict["shader_option_index"]
	
	load_audio_config()
	update_resolution(viewport_resolution_x,viewport_resolution_y)

func load_audio_config():
	AudioServer.set_bus_volume_db(0,linear_to_db(master_volume_value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"),linear_to_db(music_volume_value))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("grungle"),linear_to_db(sfx_volume_value))

func update_resolution(x,y):
	viewport_resolution_x = x
	viewport_resolution_y = y
	save_to_config()
	DisplayServer.window_set_size(Vector2i(x,y))
	
	

