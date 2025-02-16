extends Node3D

var path_trigger_array = []
var chunk_size = 9
enum direction {ORIGIN,NORTHWARD, SOUTHWARD, EASTWARD, WESTWARD, NO_CHUNK_AVAILABLE}

func check_path_triggers_have_enemy_data_to_spawn():
	for x in path_trigger_array:
		if x.has_enemies_to_spawn():
			return true
	return false

func toggle_visibility_of_path_triggers():
	for x in path_trigger_array:
		x.toggle_visibility()

func clear_path_trigger_array_of_previously_cleared():
	for x in path_trigger_array:
		if x == null:
			path_trigger_array.erase(x)

func toggle_can_select_of_path_triggers(toggle:bool):
	clear_path_trigger_array_of_previously_cleared()
	for x in path_trigger_array:
		x.toggle_can_select(toggle)

func remove_path_trigger_by_trigger_uuid(trigger_uuid):
	for x in path_trigger_array.size():
		if path_trigger_array[x-1].trigger_uuid == trigger_uuid:
			path_trigger_array.remove_at(x-1)

func create_path_trigger(chunk_id:Vector2i, trigger_id,path_out_dir:direction,trigger_depth:int):
	var path_trigger
	path_trigger = get_parent().tower_loader.expand_path_trigger_prefab.instantiate()
	path_trigger.parent_path = get_parent().get_path_follow_by_trigger_id(trigger_id)
	path_trigger.depth_counter = trigger_depth
	path_trigger.position = Vector3(chunk_id.x*chunk_size,0,chunk_id.y*chunk_size)
	path_trigger.set_trigger_id(trigger_id)
	path_trigger.path_trigger_activated.connect(get_parent()._on_path_trigger_activated)
	path_trigger_array.append(path_trigger)
	path_trigger.enemy_spawned.connect(get_parent().connect_new_enemy)
	add_child(path_trigger)
