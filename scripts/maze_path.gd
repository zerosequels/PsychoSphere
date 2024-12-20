extends Node3D

@onready var path = $Path3D
@export var trigger_uuid = ResourceUID.create_id()
var path_destination:Vector3i

enum direction {ORIGIN,NORTHWARD, SOUTHWARD, EASTWARD, WESTWARD, NO_CHUNK_AVAILABLE}
enum grid_entity {FREE,PATH,BASIC_TOWER}

var terminal_direction:direction = direction.ORIGIN
var origin_direction:direction = direction.ORIGIN
var chunk_id = Vector2i(0,0)

signal draw_path_from_points(points)

func _ready():
	path.curve = Curve3D.new()
	#print(path.curve)

func get_terminal_dir():
	return terminal_direction

func set_origin_dir(dir):
	origin_direction = dir

func get_origin_dir():
	return origin_direction

func set_terminal_dir(dir):
	terminal_direction = dir

func get_uuid():
	return trigger_uuid

func get_advancing_chunk_id():
	match terminal_direction:
		1:
			return Vector2i(chunk_id.x, chunk_id.y - 1)
		2:
			return Vector2i(chunk_id.x, chunk_id.y + 1)
		3:
			return Vector2i(chunk_id.x + 1, chunk_id.y)
		4:
			return Vector2i(chunk_id.x - 1, chunk_id.y)
	
func extend_path_by_points(points, dir):
	terminal_direction = dir
	for point in points:
		path.curve.add_point(point)
		#print(path)
	emit_signal("draw_path_from_points",points)

	
func get_terminal_point():
	return path.curve.get_point_position(path.curve.point_count - 1)
	

