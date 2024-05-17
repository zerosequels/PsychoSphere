extends Node3D

var camera_speed = 20.0
var camera_rotation_speed = 100.0

@onready var path_grid = %path_grid
@onready var camera_rotator = %camera_rotator
@onready var camera = %Camera3D
@onready var camera_boom = %camera_boom

var game_center: Transform3D
var camera_default_zoom = 15

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_camera_boom_transform()


func initialize_camera_boom_transform():
	#set camera boom origin
	game_center.origin = path_grid.map_to_local(Vector3i(0,0,0))
	camera_rotator.transform = game_center
	#set camera boom default rotiation
	#NOTE if the rotation on the y axis is zero we get artifacting in the gridmap
	camera_boom.rotation_degrees = Vector3(45,0.6,0)
	#camera_rotator.rotation_degrees = Vector3(0,0,45)
	#set camera boom zoom
	camera.position = Vector3(0,0,camera_default_zoom)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var camera_velocity = Vector3.ZERO
	
	if Input.is_action_pressed("W"):
		camera_velocity.y += camera_speed
	if Input.is_action_pressed("S"):
		camera_velocity.y -= camera_speed
	if Input.is_action_pressed("D"):
		camera_velocity.x += camera_speed	
	if Input.is_action_pressed("A"):
		camera_velocity.x -= camera_speed
	if Input.is_action_pressed("E"):
		camera_rotator.rotation_degrees.z += camera_rotation_speed * delta
	if Input.is_action_pressed("Q"):
		camera_rotator.rotation_degrees.z -= camera_rotation_speed * delta
	position += align_velocity_to_camera(camera_velocity) * delta


func align_velocity_to_camera(velocity:Vector3):
	return velocity.rotated(Vector3(0,0,1),deg_to_rad(camera_rotator.rotation_degrees.z))

