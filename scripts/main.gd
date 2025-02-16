extends Node3D

@onready var path_grid: GridMap = %path_grid
@onready var chaos_grid: GridMap = %chaos_grid
@onready var camera_controller = $phantom_camera_controller/MainCamera3D
@onready var indicator = $placement_indicator
@onready var tower_loader = $tower_loader
@onready var path_generator = $path_generator
@onready var trigger_controller = $trigger_controller
@onready var gui = %player_gui.get_gui()
@onready var hand = %card_hand
@onready var boon_selection_screen = $CanvasLayer3/boon_selection_screen
@onready var pause_menu = $CanvasLayer2/PauseMenu

var is_making_selection:bool = false
var is_game_over = false
var game_center: Vector3
var camera_default_zoom = 15
var player_health = 100
var global_branching_chance = 20.0
var currency_amount:int = 100

var under_tile_layer = -1
var chunk_size = 9

#extension points are the location of the end of the path plus one block further
var north_extension_point: Vector3
var south_extension_point: Vector3
var east_extension_point: Vector3
var west_extension_point: Vector3

#The chunk id of the next chunk to be created
var north_next_chunk_id : Vector2i = Vector2i(0,1)
var south_next_chunk_id : Vector2i = Vector2i(0,-1)
var east_next_chunk_id : Vector2i = Vector2i(1,0)
var west_next_chunk_id : Vector2i = Vector2i(-1,0)

#array to hold references to all the active towers on the map
var active_tower_array = []

var next_chunk_id_dict
var extension_point_dict

#var active_portal

var LEVEL_COUNTER = 0
var activated_trigger_depth = 0

enum direction {ORIGIN,NORTHWARD, SOUTHWARD, EASTWARD, WESTWARD, NO_CHUNK_AVAILABLE}
enum path_id {NORTH,SOUTH,EAST,WEST}
enum game_state {BIRTH, DEATH, PEACE, WAR, VICTORY}
enum grid_entity {FREE,PATH,BASIC_TOWER}

var next_available_path_id = 0

var game_status = game_state.BIRTH
var chunk_id_dict = {Vector2i(0,0): direction.ORIGIN}
#holds a key value pairing of chaos grid coordinates and tower types that let us know which tiles are occupied and by what
var taken_chaos_grid_dict = {Vector3i(0,under_tile_layer,0):grid_entity.PATH}


#Enemy spawning related stuff
var has_enemies_to_spawn:bool = false
var last_spawn_time = 0
var enemy_spawn_data_array = []
#var current_active_path: path_id

var current_tower_type = -1
var current_tower_price = 0

var is_card_hovered:bool = false

# Dictionary to store path branches
var path_branches = {}

# Dictionary to store path data
var path_dict = {}
var path_follow_dict = {}
var enemy_path_dict = {}
var enemy_path_follow_dict = {}

#EAST INCREASES ON X and WEST DECREASES ON X
#NORTH INCREASES ON Y AND SOUTH DECREASES ON Y

func _ready():
	GlobalAudio.stop_lab_theme()
	GlobalAudio.play_main_theme()
	TowerAndBoonData.increase_currency.connect(_on_currency_increase)
	TowerAndBoonData.unlock_tower.connect(_on_tower_unlocked)
	TowerAndBoonData.refresh_card_cost.connect(_refresh_card_prices)
	boon_selection_screen.close_menu.connect(_on_boon_selection_screen_closed)
	
	if WaveData.check_is_reset():
		%PauseMenu.fade_out_menu()
		is_game_over = false
		hand.deselect_card()
	hand.tower_toggled.connect(_on_tower_toggled)
	hand.price_update.connect(_on_price_update)
	hand._is_card_hovered.connect(_on_card_hovered)
	set_awareness_gui(currency_amount)
	
	camera_controller.chaos_grid = chaos_grid
	camera_controller.path_grid = path_grid
	camera_controller.chaos_grid_cell_clicked.connect(_on_chaos_cell_clicked)
	camera_controller.chaos_grid_cell_hovered.connect(_on_chaos_grid_cell_hovered)
	camera_controller.hide_indicator.connect(_on_hide_indicator)
	
	# Initialize paths
	initialize_paths()
	initialize_dict()
	initialize_core_pathing()

func initialize_paths():
	# Create initial paths for each direction
	var directions = ["north", "south", "east", "west"]
	for i in range(directions.size()):
		var dir = directions[i]
		var path = Path3D.new()
		var path_follow = PathFollow3D.new()
		var enemy_path = Path3D.new()
		var enemy_path_follow = PathFollow3D.new()
		
		# Setup paths
		path.name = dir + "_path_0"
		path_follow.name = dir + "_path_follow_0"
		enemy_path.name = dir + "_enemy_path_0"
		enemy_path_follow.name = dir + "_enemy_path_follow_0"
		
		# Initialize curves
		path.curve = Curve3D.new()
		enemy_path.curve = Curve3D.new()
		
		# Add initial points based on direction
		match i:
			0: # North
				path.curve.add_point(Vector3(0, 0, 0))
				path.curve.add_point(Vector3(0, 0, 1))
				enemy_path.curve.add_point(Vector3(0.5, 1, 0.5))
				enemy_path.curve.add_point(Vector3(0.5, 1, 1.5))
			1: # South
				path.curve.add_point(Vector3(0, 0, 0))
				path.curve.add_point(Vector3(0, 0, -1))
				enemy_path.curve.add_point(Vector3(0.5, 1, 0.5))
				enemy_path.curve.add_point(Vector3(0.5, 1, -0.5))
			2: # East
				path.curve.add_point(Vector3(0, 0, 0))
				path.curve.add_point(Vector3(1, 0, 0))
				enemy_path.curve.add_point(Vector3(0.5, 1, 0.5))
				enemy_path.curve.add_point(Vector3(1.5, 1, 0.5))
			3: # West
				path.curve.add_point(Vector3(0, 0, 0))
				path.curve.add_point(Vector3(-1, 0, 0))
				enemy_path.curve.add_point(Vector3(0.5, 1, 0.5))
				enemy_path.curve.add_point(Vector3(-0.5, 1, 0.5))
		
		# Setup path follows
		path_follow.transform.origin = path.curve.get_point_position(1)
		enemy_path_follow.transform.origin = enemy_path.curve.get_point_position(1)
		
		# Add to scene
		add_child(path)
		path.add_child(path_follow)
		add_child(enemy_path)
		enemy_path.add_child(enemy_path_follow)
		
		# Store in dictionaries
		path_dict[i] = path
		path_follow_dict[i] = path_follow
		enemy_path_dict[i] = enemy_path
		enemy_path_follow_dict[i] = enemy_path_follow
		
		# Initialize branch tracking
		path_branches[i] = 0

func create_path_branch(parent_path_id: int) -> int:
	var parent_path = path_dict[parent_path_id]
	var branch_id = path_branches[parent_path_id] + 1
	path_branches[parent_path_id] = branch_id
	
	# Create new paths for the branch
	var path = Path3D.new()
	var path_follow = PathFollow3D.new()
	var enemy_path = Path3D.new()
	var enemy_path_follow = PathFollow3D.new()
	
	# Setup paths
	var dir_name = parent_path.name.split("_")[0]
	path.name = dir_name + "_path_" + str(branch_id)
	path_follow.name = dir_name + "_path_follow_" + str(branch_id)
	enemy_path.name = dir_name + "_enemy_path_" + str(branch_id)
	enemy_path_follow.name = dir_name + "_enemy_path_follow_" + str(branch_id)
	
	# Initialize curves
	path.curve = Curve3D.new()
	enemy_path.curve = Curve3D.new()
	
	# Copy parent path points up to branching point
	var branch_point_idx = parent_path.curve.point_count - 1
	for i in range(branch_point_idx + 1):
		var point = parent_path.curve.get_point_position(i)
		path.curve.add_point(point)
		enemy_path.curve.add_point(point + Vector3(0.5, 1, 0.5))
	
	# Setup path follows
	path_follow.transform.origin = path.curve.get_point_position(branch_point_idx)
	enemy_path_follow.transform.origin = enemy_path.curve.get_point_position(branch_point_idx)
	
	# Add to scene
	add_child(path)
	path.add_child(path_follow)
	add_child(enemy_path)
	enemy_path.add_child(enemy_path_follow)
	
	# Store in dictionaries with new unique ID
	var new_path_id = path_dict.size()
	path_dict[new_path_id] = path
	path_follow_dict[new_path_id] = path_follow
	enemy_path_dict[new_path_id] = enemy_path
	enemy_path_follow_dict[new_path_id] = enemy_path_follow
	
	return new_path_id

func initialize_dict():
	# Only initialize the extension points and next chunk IDs
	next_chunk_id_dict = {0:north_next_chunk_id,1:south_next_chunk_id,2:east_next_chunk_id,3:west_next_chunk_id}
	extension_point_dict = {0:north_extension_point,1:south_extension_point,2:east_extension_point,3:west_extension_point}

func get_next_available_path_id():
	var next_id = next_available_path_id
	next_available_path_id += 1
	return next_id

func _on_tower_unlocked(tower_type):
	hand.add_card_by_type(tower_type)


func _on_price_update(type,price):
	current_tower_price = price
	

func spawn_enemies():
	print("spawning enemies")
	for x in trigger_controller.path_trigger_array:
		x.load_enemy_spawn_data()
	has_enemies_to_spawn = true

func connect_new_enemy(enemy):
	enemy.reached_the_center.connect(_on_enemy_reached_center)
	enemy.enemy_killed.connect(_on_enemy_killed)
	WaveData.register_enemy_to_active_enemy_array(enemy)

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
		print("no enemies left to spawn, at this opportunity")
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
	#path_grid.map_to_local(Vector3i(0,0,0))
	#cardinal cubes
	#east
	path_grid.set_cell_item(Vector3i(1,0,0),0,0)
	occupy_chaos_grid(Vector3i(1,under_tile_layer,0),grid_entity.PATH)
	extend_path(path_dict[2],enemy_path_dict[2],Vector3(chunk_size/2,0,0))
	
	extension_point_dict[2] = Vector3i((chunk_size/2)+1,0,0)
	next_chunk_id_dict[2] = Vector2i(1,0)
	trigger_controller.create_path_trigger(next_chunk_id_dict[2],2,direction.EASTWARD,0)
	
	#north
	path_grid.set_cell_item(Vector3i(0,0,1),0,0)
	occupy_chaos_grid(Vector3i(0,under_tile_layer,1),grid_entity.PATH)
	extend_path(path_dict[0],enemy_path_dict[0],Vector3(0,0,chunk_size/2))
	extension_point_dict[0] = Vector3i(0,0,(chunk_size/2)+1)
	next_chunk_id_dict[0] = Vector2i(0,1)
	trigger_controller.create_path_trigger(next_chunk_id_dict[0],0,direction.NORTHWARD,0)
	
	#west
	path_grid.set_cell_item(Vector3i(-1,0,0),0,0)
	occupy_chaos_grid(Vector3i(-1,under_tile_layer,0),grid_entity.PATH)
	extend_path(path_dict[3],enemy_path_dict[3],Vector3(-chunk_size/2,0,0))
	extension_point_dict[3] = Vector3i((-chunk_size/2)-1,0,0)
	next_chunk_id_dict[3] = Vector2i(-1,0)
	trigger_controller.create_path_trigger(next_chunk_id_dict[3],3,direction.WESTWARD,0)
	
	#south
	path_grid.set_cell_item(Vector3i(0,0,-1),0,0)
	occupy_chaos_grid(Vector3i(0,under_tile_layer,-1),grid_entity.PATH)
	extend_path(path_dict[1],enemy_path_dict[1],Vector3(0,0,-chunk_size/2))
	extension_point_dict[1] = Vector3i(0,0,(-chunk_size/2)-1)
	next_chunk_id_dict[1] = Vector2i(0,-1)
	trigger_controller.create_path_trigger(next_chunk_id_dict[1],1,direction.SOUTHWARD,0)
	
	#create undertile
	create_undertile(Vector2i(0,0))


func get_extension_point_by_path_id(path_type):
	return extension_point_dict[path_type]

func procedural_chunk_generation_method(chunk_id:Vector2i, path_type, path_out_dir:direction, generation_mode:int,branch_option_dirs):
	# Initialize branching variables
	var should_create_primary_branch = false
	var should_create_secondary_branch = false
	var primary_branch_out_dir = direction.NO_CHUNK_AVAILABLE
	var secondary_branch_out_dir = direction.NO_CHUNK_AVAILABLE
	
	# Set branching based on available directions
	if !branch_option_dirs.is_empty():
		primary_branch_out_dir = branch_option_dirs[0]
		should_create_primary_branch = does_event_happen(global_branching_chance)
		
		if branch_option_dirs.size() > 1:
			secondary_branch_out_dir = branch_option_dirs[1]
			should_create_secondary_branch = does_event_happen(global_branching_chance)
	
	print("creating procedural chunk")
	var exit_offset = randi_range(-3,3)
	var primary_branch_exit_offset = randi_range(-3,3)
	var secondary_branch_exit_offset = randi_range(-3,3)
	#grab extension point based on path_id
	var extension_point = get_extension_point_by_path_id(path_type)
	
	#define exit point based on path_out_dir
	var exit_point: Vector3i
	var new_extension_point: Vector3i
	var next_chunk_id: Vector2i
	
	#define potential exit point and connecting point for primary branch
	var primary_branch_exit_point: Vector3i
	var primary_branch_connection_point: Vector3i
	
	#define potential exit point and connecting point for secondary branch
	var secondary_branch_exit_point: Vector3i
	var secondary_branch_connection_point: Vector3i
	
	match path_out_dir:
		direction.NORTHWARD:
			exit_point = chunk_to_grid_coord(Vector2i((chunk_size/2) + exit_offset,chunk_size-1),chunk_id)
			new_extension_point = Vector3i(exit_point.x,exit_point.y+1,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x,chunk_id.y + 1)
		direction.SOUTHWARD:
			exit_point = chunk_to_grid_coord(Vector2i((chunk_size/2) + exit_offset,0),chunk_id)
			new_extension_point = Vector3i(exit_point.x,exit_point.y - 1,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x,chunk_id.y - 1)
		direction.EASTWARD:
			exit_point = chunk_to_grid_coord(Vector2i(chunk_size-1,(chunk_size/2) + exit_offset),chunk_id)
			new_extension_point = Vector3i(exit_point.x +1,exit_point.y,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x + 1,chunk_id.y)
		direction.WESTWARD:
			exit_point = chunk_to_grid_coord(Vector2i(0,(chunk_size/2) + exit_offset),chunk_id)
			new_extension_point = Vector3i(exit_point.x -1,exit_point.y,exit_point.z)
			next_chunk_id = Vector2i(chunk_id.x -1,chunk_id.y)
	
	update_extension_point_by_path(path_type,new_extension_point,next_chunk_id, path_out_dir)

	# Generate a random path within the chunk based on generation mode
	print("generation mode: ",generation_mode)
	print("branch out dir options",branch_option_dirs)
	var points: Array
	match generation_mode:
		0:  # Random path
			points = path_generator.generate_random_path(extension_point, exit_point, chunk_id)
		1:  # Right-angled path
			points = path_generator.generate_right_angled_path(extension_point, exit_point, chunk_id, path_out_dir)
		2:  # Multi-turn snake-like path
			points = path_generator.generate_multi_turn_snake_path(extension_point, exit_point, chunk_id, path_out_dir)
		3:  # Arc-based curved path
			points = path_generator.generate_arc_based_curved_path(extension_point, exit_point, chunk_id)
		4:  # Pure diagonal zigzag path
			points = path_generator.generate_diagonal_zigzag_path(extension_point, exit_point, chunk_id)
		_:  # Default case
			points = [extension_point, exit_point]
	
	add_points_to_path(points, path_type)

func create_chunk_with_procedural_path(chunk_id:Vector2i,path_type,path_out_dir:direction,branch_option_dirs):
	var mode = [2,3].pick_random()
	procedural_chunk_generation_method(chunk_id, path_type, path_out_dir,mode,branch_option_dirs)

func does_event_happen(percent_chance:float):
	return randf() < (percent_chance/100.0)
	

func update_extension_point_by_path(path_type, extension_point:Vector3i, next_chunk_id:Vector2i, path_out_dir:direction):
	print("updating extension point by path")
	extension_point_dict[path_type] = extension_point
	next_chunk_id_dict[path_type] = next_chunk_id
	trigger_controller.create_path_trigger(next_chunk_id, path_type ,path_out_dir, activated_trigger_depth + 1)

func get_path_follow_by_trigger_id(trigger_id):
	return enemy_path_dict[trigger_id]


func _on_chaos_cell_clicked(grid_pos:Vector3i):
	if taken_chaos_grid_dict.has(grid_pos):
		var entity_clicked = taken_chaos_grid_dict[grid_pos]
		
		#if the cell is FREE then spawn a normal tower in it's place
		if entity_clicked == grid_entity.FREE:
			if TowerAndBoonData.get_currently_selected_tower() == -1 or is_card_hovered:
				return
			instantiate_tower_by_current_type(grid_pos)
		else: 
			print(entity_clicked)
	else:
		print("ERROR:Cell not found in grid")

func _on_chaos_grid_cell_hovered(grid_pos:Vector3i):
	if TowerAndBoonData.get_currently_selected_tower() != -1:
		if taken_chaos_grid_dict.has(grid_pos):
			var entity_clicked = taken_chaos_grid_dict[grid_pos]
			if entity_clicked == grid_entity.FREE:
				indicator.visible = true
				indicator.global_position = Vector3(grid_pos.x,grid_pos.y,grid_pos.z)
			else:
				indicator.visible = false
				indicator.global_position = Vector3(0,0,0)

func instantiate_tower_by_current_type(grid_pos:Vector3i):
	var tower
	if current_tower_price <= currency_amount:
		currency_amount -= current_tower_price
		set_awareness_gui(currency_amount)
	else:
		return 
	tower = tower_loader.get_current_tower_instance()
			
	tower.transform.origin = Vector3(grid_pos.x,grid_pos.y,grid_pos.z)
	if tower.has_method("set_tower_price"):
		tower.set_tower_price(current_tower_price)
	active_tower_array.append(tower)
	%chaos_grid.add_child(tower)
	increment_cost_of_tower_by_type()
	GlobalAudio.on_tower_placed_audio_stream_player()

func increment_cost_of_tower_by_type():
	hand.increment_cost_by_tower_type(TowerAndBoonData.get_currently_selected_tower())

#TODO: Fix the below error, perhaps by creating a a new tile type that represents an end

#ERROR: If there is a NO CHUNK AVAILABLE then there will be no path trigger 
#which will cause a null pointer crash on this method	

func create_chunk(chunk_id:Vector2i,path_type:path_id):
	#check if current chunk is available
	if chunk_id_dict.has(chunk_id):
		return
	#decide if the new chunk's exit point will be north, south, east, or west
	#excluding options already taken
	var available_out_dirs = get_available_chunk_dir(chunk_id)
	#print(chunk_id_dict)
	if available_out_dirs.size() == 0:
		print("No chunk available ERROR")
		print("aborting chunk creation, NO CHUNK AVAILABLE")
		return
	var option_index = randi_range(0,available_out_dirs.size()-1)
	var chunk_out_dir = available_out_dirs[option_index]
	available_out_dirs.remove_at(option_index)
	var branch_option_dirs = available_out_dirs.duplicate(true)
	#update the array of taken chunk ids
	chunk_id_dict[chunk_id] = chunk_out_dir
	# determine the type of chunk generation from a list of sub types
	#TODO add more than just linear chunk pathing 
	create_chunk_with_procedural_path(chunk_id,path_type,chunk_out_dir,branch_option_dirs)
	#create the undertile
	create_undertile(chunk_id)

#TODO: change this to check against the array of triggers.
func check_cursor_against_triggers(cursor:Vector2i):
	return next_chunk_id_dict.values().has(cursor)

func get_available_chunk_dir(chunk_id:Vector2i):
	var options = []
	var cursor:Vector2i
	print("adding options with cursor")
	#check north
	cursor = Vector2i(chunk_id.x,chunk_id.y + 1)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		print(cursor)
		options.append(direction.NORTHWARD)
	#check south
	cursor = Vector2i(chunk_id.x,chunk_id.y - 1)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		print(cursor)
		options.append(direction.SOUTHWARD)
	#check east
	cursor = Vector2i(chunk_id.x + 1,chunk_id.y)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		print(cursor)
		options.append(direction.EASTWARD)
	#check west
	cursor = Vector2i(chunk_id.x - 1,chunk_id.y)
	if !chunk_id_dict.has(cursor) and !check_cursor_against_triggers(cursor):
		print(cursor)
		options.append(direction.WESTWARD)
	#decide randomly from available options

	return options

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
	point = Vector3(point.x, 0, point.z)
	
	# Grab previous point
	var index = path.curve.point_count - 1
	var previous_point = path.curve.get_point_position(index)
	
	# Get the grid positions for start and end points
	var start_grid = Vector3i(previous_point.x, previous_point.y, previous_point.z)
	var end_grid = Vector3i(point.x, point.y, point.z)
	
	# Calculate the direction vector
	var direction = end_grid - start_grid
	var steps_x = abs(direction.x)
	var steps_z = abs(direction.z)
	
	# Create a point for each grid cell we pass through
	var current_pos = start_grid
	
	# Handle horizontal movement first
	var step_x = sign(direction.x)
	for x in range(steps_x):
		current_pos.x += step_x
		var grid_point = Vector3(current_pos.x, 0, current_pos.z)
		path_grid.set_cell_item(grid_point, 0, 0)
		occupy_chaos_grid(Vector3i(current_pos.x, under_tile_layer, current_pos.z), grid_entity.PATH)
		path.curve.add_point(grid_point)
	
	# Then handle vertical movement
	var step_z = sign(direction.z)
	for z in range(steps_z):
		current_pos.z += step_z
		var grid_point = Vector3(current_pos.x, 0, current_pos.z)
		path_grid.set_cell_item(grid_point, 0, 0)
		occupy_chaos_grid(Vector3i(current_pos.x, under_tile_layer, current_pos.z), grid_entity.PATH)
		path.curve.add_point(grid_point)
	
	# Add the final point if it's not already added
	if current_pos != end_grid:
		path_grid.set_cell_item(point, 0, 0)
		occupy_chaos_grid(Vector3i(point.x, under_tile_layer, point.z), grid_entity.PATH)
		path.curve.add_point(point)
	
	copy_adjusted_path(path, enemy_path)

func print_all_points_in_path(path: Path3D):
	for x in path.curve.point_count:
		print(path.curve.get_point_position(x))

func occupy_chaos_grid(cursor_position:Vector3i, ge:grid_entity):
	taken_chaos_grid_dict[cursor_position] = ge

func add_points_to_path(points_to_add:Array, path_type):
	var path = path_dict[path_type]
	var path_follow = path_follow_dict[path_type]
	var enemy_path = enemy_path_dict[path_type]
	
	for point in points_to_add:
		extend_path(path, enemy_path, point)

func copy_adjusted_path(original_path: Path3D, target_path: Path3D):
	target_path.curve.clear_points()
	
	# Copy all points with the height adjustment
	for count in original_path.curve.point_count:
		var original_point = original_path.curve.get_point_position(count)
		var new_point = original_point + Vector3(0.5, 1, 0.5)  # Offset for enemy path
		target_path.curve.add_point(new_point)
		

func update_game_status(gs:game_state):
	game_status = gs
	match gs:
		game_state.BIRTH:
			pass
			#print("game state: BIRTH")
		game_state.DEATH:
			is_game_over = true
			GlobalAudio.play_game_over()
			await get_tree().create_timer(4).timeout
			pause_menu.game_over_pause()
		game_state.VICTORY:
			#print("game state: DEATH")
			is_game_over = true
			pause_menu.victory_pause()
		game_state.WAR:
			LEVEL_COUNTER = LEVEL_COUNTER + 1
			set_difficulty_gui(LEVEL_COUNTER)
			WaveData.set_total_number_of_waves(LEVEL_COUNTER)
			#print("Level:%s"%LEVEL_COUNTER)
		game_state.PEACE:
			trigger_controller.toggle_visibility_of_path_triggers()
			#print("game state: PEACE")
	

func _on_path_trigger_activated(trigger_id,trigger_uuid,depth):
	hand.deselect_card()
	GlobalAudio.path_trigger_selected_audio_stream_player()
	show_path_trigger_choice_menu(trigger_id,trigger_uuid,depth)
	

func show_path_trigger_choice_menu(trigger_id,trigger_uuid,depth):
	$phantom_camera_controller.toggle_is_camera_frozen(true)
	trigger_controller.toggle_can_select_of_path_triggers(false)
	is_making_selection = true
	hand.toggle_hide_hand(true)
	gui.visible = false
	$CanvasLayer/player_gui.visible = false
	$speed_box_layer/speed_box.visible = false
	boon_selection_screen.load_new_boons_from_data(trigger_id,trigger_uuid,depth)
	boon_selection_screen.visible = true

func restore_game_ui():
	$phantom_camera_controller.toggle_is_camera_frozen(false)
	trigger_controller.toggle_can_select_of_path_triggers(true)
	is_making_selection = false
	hand.toggle_hide_hand(false)
	if TowerAndBoonData.get_currently_selected_tower() != -1:
		hand.select_card(current_tower_type)
	gui.visible = true
	$CanvasLayer/player_gui.visible = true
	$speed_box_layer/speed_box.visible = true
	boon_selection_screen.visible = false

func enemy_wave_activation_sequence(trigger_id,trigger_uuid,depth):
	activated_trigger_depth = depth 
	update_game_status(game_state.WAR)
	create_chunk(next_chunk_id_dict[trigger_id],trigger_id)
	copy_adjusted_path(path_dict[trigger_id],enemy_path_dict[trigger_id])
	trigger_controller.clear_path_trigger_array_of_previously_cleared()
	trigger_controller.toggle_visibility_of_path_triggers()
	spawn_enemies()
	

func _on_enemy_reached_center(damage, enemy_uuid):
	#print("center reached")
	GlobalAudio.on_enemy_reached_center_stream_player()
	WaveData.remove_enemy_by_uuid(enemy_uuid)
	player_health = player_health - damage
	set_health_gui(player_health)

func _on_currency_increase(exp):
	currency_amount += exp
	set_awareness_gui(currency_amount)

func _on_enemy_killed(exp,enemy_uuid):
	GlobalAudio.on_enemy_dead_audio_stream_player()
	currency_amount += exp
	set_awareness_gui(currency_amount)
	WaveData.remove_enemy_by_uuid(enemy_uuid)

func _on_boon_selection_screen_closed(trigger_id,trigger_uuid,depth):
	GlobalAudio.boon_selected_audio_stream_player()
	restore_game_ui()
	enemy_wave_activation_sequence(trigger_id,trigger_uuid,depth)

func set_health_gui(value:int):
	gui.set_health(value)

func set_difficulty_gui(value:int):
	gui.set_difficulty(value)

func set_awareness_gui(value:int):
	gui.set_awareness(value)
	
func _on_tower_toggled(tower_type:int, tower_price:int):
	TowerAndBoonData.set_currently_selected_tower(tower_type)
	if current_tower_type == tower_type:
		current_tower_type = -1
		indicator.visible = false
		indicator.global_position = Vector3(0,0,0)
		GlobalAudio.on_card_deselected_audio_stream_player()
	else:
		current_tower_type = tower_type
		current_tower_price = tower_price
		indicator.visible = true
		GlobalAudio.on_card_select_audio_stream_player()
	
func _on_hide_indicator():
	indicator.visible = false
	indicator.global_position = Vector3(0,0,0)

func _on_card_hovered(is_hovered:bool):
	is_card_hovered = is_hovered
	
func _refresh_card_prices():
	hand.refresh_card_prices()

func _process(delta):
	if Input.is_action_just_released("toggle_range_visibility_mode"):
		TowerAndBoonData.set_range_visibility_mode(!TowerAndBoonData.get_is_range_visibility_mode_toggled())
	if Input.is_action_just_released("right_click"):
		current_tower_type = -1
		hand.deselect_card()
	
	#WAR MODE
	if (game_status == game_state.WAR):
		if WaveData.is_active_enemy_array_empty() and !has_enemies_to_spawn:
			update_game_status(game_state.PEACE)
		else:
			if has_enemies_to_spawn:
				has_enemies_to_spawn = trigger_controller.check_path_triggers_have_enemy_data_to_spawn()
	#PEACE

	#DEATH CHECK
	if player_health <= 0 and !is_game_over:
		update_game_status(game_state.DEATH)
	if LEVEL_COUNTER == 101 and !is_game_over:
		update_game_status(game_state.VICTORY)
