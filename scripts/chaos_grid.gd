extends GridMap


# Called when the node enters the scene tree for the first time.
func _ready():
	var shader = load("res://data/spacial_plexus_2.gdshader")
	
	var material = ShaderMaterial.new()
	material.shader = shader
	#material.set_shader_parameter("octaves",PlayerData.background_shader_octave)
	material.set_shader_parameter("octaves",PlayerData.background_shader_octave)
	var resolution = Vector2(PlayerData.background_plexus_resolution_x,PlayerData.background_plexus_resolution_y)
	material.set_shader_parameter("resolution",resolution)
	
	material.set_shader_parameter("line_color",Vector3(0.49,0.18,0.68))
	
	material.set_shader_parameter("zoom_factor",10.0)
	material.set_shader_parameter("zoom_coef",1.1)
	material.set_shader_parameter("brightness",5)
	material.set_shader_parameter("rotation_angle",0.5)
	
	var mesh_item = mesh_library.get_item_mesh(1)
	if mesh_item != null:
		var item_material = mesh_item.surface_get_material(0)
		if item_material == null:
			mesh_item.surface_set_material(0, material)
		else:
			mesh_item.surface_set_material(0, material)
	
	
