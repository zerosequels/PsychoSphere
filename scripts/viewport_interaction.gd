extends Camera3D

@export var path_grid: GridMap
@export var chaos_grid: GridMap

var time_since_ping = 0
var ping_interval_ms = 150

signal chaos_grid_cell_clicked(grid_position:Vector3)
signal chaos_grid_cell_hovered(grid_position:Vector3)
signal hide_indicator()

func _process(delta):
	process_ping_opportunity()

func _input(event):
	if event.is_action_pressed("click"):
		get_grid_cell_from_raycast(shoot_ray())

func process_ping_opportunity():
	if Time.get_ticks_msec() > (time_since_ping + ping_interval_ms):
		get_hoverable_from_raycast(shoot_ray())
		time_since_ping = Time.get_ticks_msec()

func shoot_ray():
	var mouse_position = get_viewport().get_mouse_position()
	var ray_length = 1000
	var from = project_ray_origin(mouse_position)
	var to = from + project_ray_normal(mouse_position) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to

	var raycast_result = space.intersect_ray(ray_query)
	return raycast_result
	
func get_grid_cell_from_raycast(raycast: Dictionary):
	if raycast.is_empty():
		return
	elif raycast["collider"] == path_grid:
		print("path_grid")
	elif raycast["collider"] == chaos_grid:
		var grid_pos = chaos_grid.local_to_map(raycast.position)
		emit_signal("chaos_grid_cell_clicked",grid_pos)
	elif raycast["collider"].get_name() == "expand_path_static_body": 
		raycast["collider"].get_parent().get_parent().activate_trigger()
	else:
		print(raycast)
		
func get_hoverable_from_raycast(raycast:Dictionary):
	if raycast.is_empty():
		emit_signal("hide_indicator")
		return
	elif raycast["collider"].get_name() == "static_mouse_detection_body":
		raycast["collider"].mouse_detector_hit()
	elif raycast["collider"] == chaos_grid:
		var grid_pos = chaos_grid.local_to_map(raycast.position)
		emit_signal("chaos_grid_cell_hovered",grid_pos)
		#emit_signal("hide_indicator")
	else:
		emit_signal("hide_indicator")
		
	
