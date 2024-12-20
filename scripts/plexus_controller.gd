extends Node2D


var resolution_x
var resolution_y
var octaves

@onready var colorRect:ColorRect = $CanvasLayer/ColorRect

func _ready():
	
	load_plexus_settings()


func load_plexus_settings():
	resolution_x = PlayerData.background_plexus_resolution_x
	resolution_y = PlayerData.background_plexus_resolution_y
	octaves = PlayerData.background_shader_octave
	
	var resolution = Vector2(resolution_x,resolution_y)
	
	colorRect.material.set_shader_parameter("octaves", octaves)
	colorRect.material.set_shader_parameter("resolution",resolution)

	
