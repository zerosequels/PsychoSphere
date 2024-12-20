extends Node3D

@onready var path_grid = $path_grid
@onready var chaos_grid = $chaos_grid

@onready var maze_path_prefab = preload("res://scenes/maze_path.tscn")

var maze_path_array = []
var chunk_id_dict = {Vector2i(0,0): chunk_entity.TAKEN}
var under_tile_layer = -1
var chunk_size = 9
enum grid_entity {FREE,PATH,BASIC_TOWER}
enum chunk_entity {FREE,TAKEN}
var taken_chaos_grid_dict = {Vector3i(0,under_tile_layer,0):grid_entity.PATH}

#This is only for creating the central starting chunk 
func _initialize(starting_path_count:int):
	#print(starting_path_count)
	#clamp number of starting paths to 1 - 4 range and then add that number of paths to a path dictionary
	starting_path_count = clamp(starting_path_count,1,4)
	#cardinal cubes
	#north
	if starting_path_count >= 1:
		create_new_maze_path([Vector3i(4,0,4),Vector3i(4,0,3),Vector3i(4,0,2),Vector3i(4,0,1),Vector3i(4,0,0)],1,Vector2i(0,0))
	#south
	if starting_path_count >= 2:
		create_new_maze_path([Vector3i(4,0,4),Vector3i(4,0,5),Vector3i(4,0,6),Vector3i(4,0,7),Vector3i(4,0,8)],2,Vector2i(0,0))
	#east
	if starting_path_count >= 3:
		create_new_maze_path([Vector3i(4,0,4),Vector3i(5,0,4),Vector3i(6,0,4),Vector3i(7,0,4),Vector3i(8,0,4)],3,Vector2i(0,0))
	#west
	if starting_path_count >= 4:
		create_new_maze_path([Vector3i(4,0,4),Vector3i(3,0,4),Vector3i(2,0,4),Vector3i(1,0,4),Vector3i(0,0,4)],4,Vector2i(0,0))
	create_undertile(Vector2i(0,0))
	
#This function must create a new maze path node, add it to the array, add it to the scene tree
#The maze path should originate at its destination 
#finally return the uuid of the new path
func create_new_maze_path(points, dir,chunk_id):
	var new_path = maze_path_prefab.instantiate()
	new_path.chunk_id = chunk_id
	new_path.draw_path_from_points.connect(_on_draw_path_from_points)
	maze_path_array.append(new_path)
	add_child(new_path)
	extend_maze_path_by_uuid(new_path.get_uuid(),points, dir)
	return new_path.get_uuid()

func extend_maze_path_by_uuid(uuid,points,dir):
	var path = get_maze_path_by_id(uuid)
	if path == null:
		print("path not found, unable to extend")
		return
	path.extend_path_by_points(points,dir)

func get_maze_path_by_id(uuid):
	for path in maze_path_array:
		if path.get_uuid() == uuid:
			return path
	print("path not found")
	
func _on_draw_path_from_points(points):
	#print(points)
	for point in points:
		path_grid.set_cell_item(point,0,0)
		occupy_chaos_grid(Vector3(point.x,under_tile_layer,point.z),grid_entity.PATH)

func generate_chunk_by_uuid(uuid):
	var path = get_maze_path_by_id(uuid)
	var advancement_options = calculate_advancement_options(path.get_advancing_chunk_id()) 
	ChunkUtils.generate_chunk(path,advancement_options)
	create_undertile(path.get_advancing_chunk_id())

func generate_random_chunk():
	var path = maze_path_array.pick_random()
	var advancement_options = calculate_advancement_options(path.get_advancing_chunk_id()) 
	ChunkUtils.generate_chunk(maze_path_array.pick_random(),advancement_options)
	#need to update terminal point
	create_undertile(path.get_advancing_chunk_id())

func calculate_advancement_options(chunk_id:Vector2i):
	var options = []
	var cursor:Vector2i
	#check north
	cursor = Vector2i(chunk_id.x - 1,chunk_id.y)
	if !chunk_id_dict.has(cursor): #and !check_cursor_against_triggers(cursor):
		options.append(1)
	#check south
	cursor = Vector2i(chunk_id.x + 1,chunk_id.y)
	if !chunk_id_dict.has(cursor): # and !check_cursor_against_triggers(cursor):
		options.append(2)
	#check east
	cursor = Vector2i(chunk_id.x,chunk_id.y + 1)
	if !chunk_id_dict.has(cursor): # and !check_cursor_against_triggers(cursor):
		options.append(3)
	#check west
	cursor = Vector2i(chunk_id.x,chunk_id.y - 1)
	if !chunk_id_dict.has(cursor): # and !check_cursor_against_triggers(cursor):
		options.append(4)
	return options

func create_undertile(chunk_id:Vector2i):
	print("creating undertile")
	print(chunk_id)
	var x_coord
	var z_coord
	for x in chunk_size:
		for y in chunk_size:
			x_coord = (x-(chunk_size/2)+ chunk_id.x * chunk_size) + 4
			z_coord = (y-(chunk_size/2)+ chunk_id.y * chunk_size) + 4
			var cursor = Vector3i(x_coord,under_tile_layer,z_coord)
			chaos_grid.set_cell_item(cursor,1,0)

			#print(cursor)
			if !taken_chaos_grid_dict.has(cursor):
				occupy_chaos_grid(cursor,grid_entity.FREE)
				#taken_chaos_grid_dict[cursor] = grid_entity.FREE

func occupy_chaos_grid(cursor_position:Vector3i,ge:grid_entity):
	taken_chaos_grid_dict[cursor_position] = ge
