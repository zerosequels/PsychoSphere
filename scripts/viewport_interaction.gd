extends Camera3D

@export var path_grid: GridMap
@export var chaos_grid: GridMap

signal chaos_grid_cell_clicked(grid_position:Vector3)

func _input(event):
	if event.is_action_pressed("click"):
		shoot_ray()
	
func shoot_ray():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	#ray_query.collide_with_areas = true
	#ray_query.collide_with_bodies = true

	var raycast_result = space.intersect_ray(ray_query)
	get_grid_cell_from_raycast(raycast_result)
	
func get_grid_cell_from_raycast(raycast: Dictionary):
	if raycast.is_empty():
		return
	elif raycast["collider"] == path_grid:
		print("path_grid")
	elif raycast["collider"] == chaos_grid:
		#print("chaos_grid")
		var grid_pos = chaos_grid.local_to_map(raycast.position)
		#print(raycast)
		emit_signal("chaos_grid_cell_clicked",grid_pos)
	elif raycast["collider"].get_name() == "expand_path_static_body": 
		raycast["collider"].get_parent().get_parent().activate_trigger()
	else:
		print(raycast)
		
	
