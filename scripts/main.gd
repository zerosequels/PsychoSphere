extends Node3D

@onready var path_grid: GridMap = %path_grid
@onready var chaos_grid: GridMap = %chaos_grid
@onready var camera_controller = $phantom_camera_controller/MainCamera3D

@onready var north_path: Path3D = %north_path
@onready var north_path_follow: PathFollow3D = %north_path_follow

@onready var north_enemy_path: Path3D = %north_enemy_path
@onready var north_enemy_path_follow: PathFollow3D = %north_enemy_path_follow

@onready var south_path: Path3D = %south_path
@onready var south_path_follow: PathFollow3D = %south_path_follow

@onready var south_enemy_path: Path3D = %south_enemy_path
@onready var south_enemy_path_follow: PathFollow3D = %south_enemy_path_follow

@onready var east_path: Path3D = %east_path
@onready var east_path_follow: PathFollow3D = %east_path_follow

@onready var east_enemy_path: Path3D = %east_enemy_path
@onready var east_enemy_path_follow: PathFollow3D = %east_enemy_path_follow

@onready var west_path: Path3D = %west_path
@onready var west_path_follow: PathFollow3D = %west_path_follow

@onready var west_enemy_path: Path3D = %west_enemy_path
@onready var west_enemy_path_follow: PathFollow3D = %west_enemy_path_follow

@onready var expand_path_trigger_prefab = preload("res://scenes/expand_path_button.tscn")

@onready var basic_tower_prefab = preload("res://scenes/basic_tower.tscn")
@onready var enemy_energy_portal = preload("res://scenes/portal_vfx.tscn")

@onready var gui = %player_gui.get_gui()

var game_center: Vector3
var camera_default_zoom = 15
@export var player_health = 100
var currency_amount:int = 100

var under_tile_layer = -1
var chunk_size = 9

#extension points are the location of the end of the path plus one block further
var north_extension_point: Vector3
var south_extension_point: Vector3
var east_extension_point: Vector3
var west_extension_point: Vector3

#The chunk id of the next chunk to be created
var north_next_chunk_id : Vector2i
var south_next_chunk_id : Vector2i
var east_next_chunk_id : Vector2i
var west_next_chunk_id : Vector2i

#array to hold references to all of the active enemies currently on the map
var active_enemy_array = []
#array to hold references to all the active towers on the map
var active_tower_array = []

#var active_portal

var LEVEL_COUNTER = 0
var activated_trigger_depth = 0

enum direction {ORIGIN,NORTHWARD, SOUTHWARD, EASTWARD, WESTWARD, NO_CHUNK_AVAILABLE}
enum path_id {NORTH,SOUTH,EAST,WEST}
enum game_state {BIRTH, DEATH, PEACE, WAR}
enum grid_entity {FREE,PATH,BASIC_TOWER}

var game_status = game_state.BIRTH
var chunk_id_dict = {Vector2i(0,0): direction.ORIGIN}
#holds a key value pairing of chaos grid coordinates and tower types that let us know which tiles are occupied and by what
var taken_chaos_grid_dict = {Vector3i(0,under_tile_layer,0):grid_entity.PATH}
var path_trigger_array = []

#Enemy spawning related stuff
var has_enemies_to_spawn:bool = false
var last_spawn_time = 0
var enemy_spawn_data_array = []
#var current_active_path: path_id

#EAST INCREASES ON X and WEST DECREASES ON X
#NORTH INCREASES ON Y AND SOUTH DECREASES ON Y

func _ready():
	print("READY!")
	#reset_game_state()
	camera_controller.chaos_grid = chaos_grid
	camera_controller.path_grid = path_grid
	camera_controller.chaos_grid_cell_clicked.connect(_on_chaos_cell_clicked)
	initialize_core_pathing()

func _process(delta):
	#WAR MODE
	if (game_status == game_state.WAR):
		if active_enemy_array.is_empty() and !has_enemies_to_spawn:
			#print("All enemies destroyed")
			update_game_status(game_state.PEACE)
		else:
			if has_enemies_to_spawn:
				has_enemies_to_spawn = check_path_triggers_have_enemy_data_to_spawn()
				#process_enemy_spawn_opportunity()

	#PEACE

	#DEATH CHECK
	if player_health <= 0:
		update_game_status(game_state.DEATH)
		

func check_path_triggers_have_enemy_data_to_spawn():
	for x in path_trigger_array:
		if x.has_enemies_to_spawn():
			return true
	return false

func spawn_enemies():
	for x in path_trigger_array:
		x.load_enemy_spawn_data()
	has_enemies_to_spawn = true
	#current_active_path = path_type

func connect_new_enemy(enemy):
	enemy.reached_the_center.connect(_on_enemy_reached_center)
	enemy.enemy_killed.connect(_on_enemy_killed)
	active_enemy_array.append(enemy)

func process_enemy_spawn_opportunity():
	#var enemy_spawn_data = enemy_spawn_data_array.pop_front()
	var spawn_time = 1000
	var enemy_spawn_data
	if !enemy_spawn_data_array.is_empty():
		#print("enemy spawn data array has enemies to spawn")
		enemy_spawn_data = enemy_spawn_data_array[0]
		#print(enemy_spawn_data.time_to_spawn_ms)
		spawn_time = enemy_spawn_data.time_to_spawn_ms
	else:
		#print("no enemies left to spawn, at this opportunity")
		has_enemies_to_spawn = false
		return
	
	if Time.get_ticks_msec() > (last_spawn_time + spawn_time):
		if !enemy_spawn_data_array.is_empty():
			enemy_spawn_data = enemy_spawn_data_array.pop_front()
			#spawn_enemy(current_active_path,enemy_spawn_data)
			last_spawn_time = Time.get_ticks_msec()

	

func initialize_core_pathing():
	#core cube
	path_grid.set_cell_item(Vector3i(0,0,0),0,0)
	path_grid.map_to_local(Vector3i(0,0,0))
	#cardinal cubes
	#east
	path_grid.set_cell_item(Vector3i(1,0,0),0,0)
	occupy_chaos_grid(Vector3i(1,under_tile_layer,0),grid_entity.PATH)
	extend_path(east_path,east_enemy_path,Vector3(chunk_size/2,0,0))
	east_extension_point = Vector3i((chunk_size/2)+1,0,0)
	east_next_chunk_id = Vector2i(1,0)
	create_path_trigger(east_next_chunk_id,"east",direction.EASTWARD,0)
	#north
	path_grid.set_cell_item(Vector3i(0,0,1),0,0)
	occupy_chaos_grid(Vector3i(0,under_tile_layer,1),grid_entity.PATH)
	extend_path(north_path,north_enemy_path,Vector3(0,0,chunk_size/2))
	north_extension_point = Vector3i(0,0,(chunk_size/2)+1)
	north_next_chunk_id = Vector2i(0,1)
	create_path_trigger(north_next_chunk_id,"north",direction.NORTHWARD,0)
	#west
	path_grid.set_cell_item(Vector3i(-1,0,0),0,0)
	occupy_chaos_grid(Vector3i(-1,under_tile_layer,0),grid_entity.PATH)
	extend_path(west_path,west_enemy_path,Vector3(-chunk_size/2,0,0))
	west_extension_point = Vector3i((-chunk_size/2)-1,0,0)
	west_next_chunk_id = Vector2i(-1,0)
	create_path_trigger(west_next_chunk_id,"west",direction.WESTWARD,0)
	#south
	path_grid.set_cell_item(Vector3i(0,0,-1),0,0)
	occupy_chaos_grid(Vector3i(0,under_tile_layer,-1),grid_entity.PATH)
	extend_path(south_path,south_enemy_path,Vector3(0,0,-chunk_size/2))
	south_extension_point = Vector3i(0,0,(-chunk_size/2)-1)
	south_next_chunk_id = Vector2i(0,-1)
	create_path_trigger(south_next_chunk_id,"south",direction.SOUTHWARD,0)
	#create undertile
	create_undertile(Vector2i(0,0))


func get_extension_point_by_path_id(path_type:path_id):
	match path_type:
		path_id.NORTH:
			return north_extension_point
		path_id.SOUTH:
			return south_extension_point
		path_id.EAST:
			return east_extension_point
		path_id.WEST:
			return west_extension_point



func create_chunk_with_linear_path(chunk_id:Vector2i,path_type:path_id,path_out_dir:direction):
	
	#grab extension point based on path_id
	var extension_point = get_extension_point_by_path_id(path_type)
	
	#define exit point based on path_out_dir
	var exit_point: Vector3i
	var new_extension_point: Vector3i
	var next_chunk_id: Vector2i
	match path_out_dir:
		direction.NORTHWARD:
			exit_point = chunk_to_grid_coord(Vector2i((chunk_size/2),chunk_size-1),chunk_id)
			new_extension_point = Vector3i(exit_point.x,exit_point.y+1,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x,chunk_id.y + 1)
		direction.SOUTHWARD:
			exit_point = chunk_to_grid_coord(Vector2i((chunk_size/2),0),chunk_id)
			new_extension_point = Vector3i(exit_point.x,exit_point.y - 1,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x,chunk_id.y - 1)
		direction.EASTWARD:
			exit_point = chunk_to_grid_coord(Vector2i(chunk_size-1,(chunk_size/2)),chunk_id)
			new_extension_point = Vector3i(exit_point.x +1,exit_point.y,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x + 1,chunk_id.y)
		direction.WESTWARD:
			exit_point = chunk_to_grid_coord(Vector2i(0,(chunk_size/2)),chunk_id)
			new_extension_point = Vector3i(exit_point.x -1,exit_point.y,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x -1,chunk_id.y)
	#update the next extension point value by the path type
	
	update_extension_point_by_path(path_type,new_extension_point,next_chunk_id, path_out_dir)
	#find the intersection of these two points 
	var intersect_point:Vector3 = chunk_to_grid_coord(Vector2i((chunk_size/2),(chunk_size/2)),chunk_id)
	#add point to an array and then in order add them to the correct path
	var points = [extension_point,intersect_point,exit_point]
	add_points_to_path(points,path_type)
	
func update_extension_point_by_path(path_type:path_id, extension_point:Vector3i, next_chunk_id:Vector2i, path_out_dir:direction):

	var path_trigger
	match path_type:
		path_id.NORTH:
			north_extension_point = extension_point
			north_next_chunk_id = next_chunk_id
			create_path_trigger(north_next_chunk_id, "north",path_out_dir, activated_trigger_depth + 1)

		path_id.SOUTH:
			south_extension_point = extension_point
			south_next_chunk_id = next_chunk_id
			create_path_trigger(south_next_chunk_id, "south",path_out_dir, activated_trigger_depth + 1)

		path_id.EAST:
			east_extension_point = extension_point
			east_next_chunk_id = next_chunk_id
			create_path_trigger(east_next_chunk_id,"east",path_out_dir, activated_trigger_depth + 1)

		path_id.WEST:
			west_extension_point = extension_point
			west_next_chunk_id = next_chunk_id
			create_path_trigger(west_next_chunk_id,"west",path_out_dir, activated_trigger_depth + 1)


func create_path_trigger(chunk_id:Vector2i, trigger_id:String,path_out_dir:direction,trigger_depth:int):
	var path_trigger
	
	path_trigger = expand_path_trigger_prefab.instantiate()
	path_trigger.parent_path = get_path_follow_by_trigger_id(trigger_id)
	path_trigger.depth_counter = trigger_depth
	path_trigger.position = Vector3(chunk_id.x*chunk_size,0,chunk_id.y*chunk_size)
	path_trigger.set_trigger_id(trigger_id)
	path_trigger.path_trigger_activated.connect(_on_path_trigger_activated)
	path_trigger_array.append(path_trigger)
	path_trigger.enemy_spawned.connect(connect_new_enemy)
	add_child(path_trigger)

func get_path_follow_by_trigger_id(trigger_id):
	match trigger_id:
		"north":
			return north_enemy_path
		"south":
			return south_enemy_path
		"east":
			return east_enemy_path
		"west":
			return west_enemy_path

func _on_chaos_cell_clicked(grid_pos:Vector3i):
	if taken_chaos_grid_dict.has(grid_pos):
		var entity_clicked = taken_chaos_grid_dict[grid_pos]
		#print(grid_pos)
		#print(taken_chaos_grid_dict)
		#if the cell is FREE then spawn a normal tower in it's place
		if entity_clicked == grid_entity.FREE:
			var tower = basic_tower_prefab.instantiate()
			tower.transform.origin = Vector3(grid_pos.x,grid_pos.y,grid_pos.z)
			active_tower_array.append(tower)
			%chaos_grid.add_child(tower)
			
	else:
		print("ERROR:Cell not found in grid")
		#print(grid_pos)
	

#TODO: Fix the below error, perhaps by creating a a new tile type that represents an end

#ERROR: If there is a NO CHUNK AVAILABLE then there will be no path trigger 
#which will cause a null pointer crash on this method
func toggle_visibility_of_path_triggers():
	for x in path_trigger_array:
		x.toggle_visibility()
	

func create_chunk(chunk_id:Vector2i,path_type:path_id):
	#check if current chunk is available
	if chunk_id_dict.has(chunk_id):
		return
	
	#decide if the new chunk's exit point will be north, south, east, or west
	#excluding options already taken
	var chunk_out_dir = get_available_chunk_dir(chunk_id)

	#Handle if there is no path available
	if chunk_out_dir == direction.NO_CHUNK_AVAILABLE:
		return
	
	#update the array of taken chunk ids
	chunk_id_dict[chunk_id] = chunk_out_dir
	# determine the type of chunk generation from a list of sub types
	#TODO add more than just linear chunk pathing 
	create_chunk_with_linear_path(chunk_id,path_type,chunk_out_dir)
	
	#create the undertile
	create_undertile(chunk_id)

#TODO: change this to check against the array of triggers.
func check_cursor_against_triggers(cursor:Vector2i):
	if cursor == north_next_chunk_id or cursor == south_next_chunk_id or cursor == west_next_chunk_id or cursor == east_next_chunk_id:
		return true
	else:
		return false

func get_available_chunk_dir(chunk_id:Vector2i):
	var options = []
	var cursor:Vector2i
	#check north
	cursor = Vector2i(chunk_id.x,chunk_id.y + 1)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		options.append(direction.NORTHWARD)
	#check south
	cursor = Vector2i(chunk_id.x,chunk_id.y - 1)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		options.append(direction.SOUTHWARD)
	#check east
	cursor = Vector2i(chunk_id.x + 1,chunk_id.y)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		options.append(direction.EASTWARD)
	#check west
	cursor = Vector2i(chunk_id.x - 1,chunk_id.y)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		options.append(direction.WESTWARD)
	#decide randomly from available options
	
	if options.size() == 0:
		print("No chunk available ERROR")
		return direction.NO_CHUNK_AVAILABLE
	var option_index = randi_range(0,options.size()-1) 

	return options[option_index]

func chunk_to_grid_coord(point:Vector2i,chunk_id:Vector2i):
	var x = point.x - (chunk_size/2) + chunk_id.x * chunk_size
	var y = point.y - (chunk_size/2)+ chunk_id.y * chunk_size

	return Vector3(x,0,y)

func create_undertile(chunk_id:Vector2i):
	var x_coord
	var z_coord
	for x in chunk_size:
		for y in chunk_size:
			x_coord = (x-(chunk_size/2)+ chunk_id.x * chunk_size)
			z_coord = (y-(chunk_size/2)+ chunk_id.y * chunk_size)
			var cursor = Vector3i(x_coord,under_tile_layer,z_coord)
			chaos_grid.set_cell_item(cursor,1,0)

			#print(cursor)
			if !taken_chaos_grid_dict.has(cursor):
				occupy_chaos_grid(cursor,grid_entity.FREE)
				#taken_chaos_grid_dict[cursor] = grid_entity.FREE

func extend_path(path: Path3D, enemy_path: Path3D, point: Vector3):
	point = Vector3(point.x,0,point.z)
	
	#grab previous point
	var index = path.curve.point_count -1
	var previous_point = path.curve.get_point_position(index)
	#print("previous point")
	#print(previous_point)
	#print(point)
	#compare to new point to determine magnitide of vector
	var distance = previous_point.distance_to(point)

	#divide progress ratio by magnitude to determine steps 
	var increment = 1/distance
	for x in distance:
		var grid_cursor_position = previous_point.lerp(point,increment *(x+1))
		path_grid.set_cell_item(grid_cursor_position,0,0)
		#get grid coord from cursor position and add to taken dict
		var cursor = chaos_grid.local_to_map(Vector3i(grid_cursor_position.x,grid_cursor_position.y,grid_cursor_position.z))
		occupy_chaos_grid(Vector3(cursor.x,under_tile_layer,cursor.z),grid_entity.PATH)
	#point = point + Vector3(0.5,0.5,1)
	path.curve.add_point(point,Vector3(0,0,0),Vector3(0,0,0))
	copy_adjusted_path(path,enemy_path)
	#print_all_points_in_path(path)

func print_all_points_in_path(path: Path3D):
	print("------------")
	for x in path.curve.point_count:
		print(path.curve.get_point_position(x))
	print("------------")

func occupy_chaos_grid(cursor_position:Vector3i,ge:grid_entity):
	taken_chaos_grid_dict[cursor_position] = ge


func add_points_to_path(points_to_add:Array, path_type:path_id):
	var path
	var path_follow
	var enemy_path
	
	match path_type:
		path_id.NORTH:
			path = north_path
			path_follow = north_path_follow
			enemy_path = north_enemy_path
		path_id.SOUTH:
			path = south_path
			path_follow = south_path_follow
			enemy_path = south_enemy_path
		path_id.EAST:
			path = east_path
			path_follow = east_path_follow
			enemy_path = east_enemy_path
		path_id.WEST:
			path = west_path
			path_follow = west_path_follow
			enemy_path = west_enemy_path
	for point in points_to_add:
		extend_path(path,enemy_path,point)
		

func copy_adjusted_path(original_path:Path3D,target_path:Path3D):
	target_path.curve.clear_points()
	#print(original_path.curve.point_count)
	for count in original_path.curve.point_count:
		var new_point = original_path.curve.get_point_position(count) + Vector3(0.5,1,0.5)
		target_path.curve.add_point(new_point)
		

func update_game_status(gs:game_state):
	
	game_status = gs
	
	match gs:
		game_state.BIRTH:
			print("game state: BIRTH")
		game_state.DEATH:
			print("game state: DEATH")
		game_state.WAR:
			print("game state: WAR")
			LEVEL_COUNTER = LEVEL_COUNTER + 1
			set_difficulty_gui(LEVEL_COUNTER)
			#print("Level:%s"%LEVEL_COUNTER)
		game_state.PEACE:
			toggle_visibility_of_path_triggers()



			print("game state: PEACE")

func remove_path_trigger_by_trigger_uuid(trigger_uuid):
	for x in path_trigger_array.size():
		if path_trigger_array[x-1].trigger_uuid == trigger_uuid:
			path_trigger_array.remove_at(x-1)
	

func _on_path_trigger_activated(trigger_id,trigger_uuid,depth):
	activated_trigger_depth = depth 
	update_game_status(game_state.WAR)
	match trigger_id:
		"north":
			create_chunk(north_next_chunk_id,path_id.NORTH)

			copy_adjusted_path(north_path,north_enemy_path)
			#print("north")
		"south":
			create_chunk(south_next_chunk_id,path_id.SOUTH)

			copy_adjusted_path(south_path,south_enemy_path)
			#print("south")
		"east":
			create_chunk(east_next_chunk_id,path_id.EAST)

			copy_adjusted_path(east_path,east_enemy_path)
			#print("east")
		"west":
			create_chunk(west_next_chunk_id,path_id.WEST)

			copy_adjusted_path(west_path,west_enemy_path)
			#print("west")
	toggle_visibility_of_path_triggers()
	spawn_enemies()
	remove_path_trigger_by_trigger_uuid(trigger_uuid)

func _on_enemy_reached_center(damage, enemy_uuid):
	print("center reached")
	remove_enemy_by_uuid(enemy_uuid)
	player_health = player_health - damage
	set_health_gui(player_health)

func _on_enemy_killed(exp,enemy_uuid):
	currency_amount += exp
	set_awareness_gui(currency_amount)
	remove_enemy_by_uuid(enemy_uuid)

func remove_enemy_by_uuid(uuid:int):
	for x in active_enemy_array:
		if x.enemy_uuid == uuid:
			active_enemy_array.erase(x)

func set_health_gui(value:int):
	gui.set_health(value)

func set_difficulty_gui(value:int):
	gui.set_difficulty(value)

func set_awareness_gui(value:int):
	gui.set_awareness(value)
	



