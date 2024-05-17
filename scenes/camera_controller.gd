extends Node3D

@onready var camera_target = %camera_boom
@onready var camera_base = %base
@onready var camera_rotator = %rotator
#@onready var secondary_rotator = %secondary_rotator
var camera_speed = 10 
var camera_rotation_speed = 100.0

var translation_input = Vector3.ZERO
var camera_velocity = Vector3.ZERO

const max_speed = 10
const accel = 75
const friction = 100

func get_input(delta):
	translation_input.x = int(Input.is_action_pressed("D")) - int(Input.is_action_pressed("A"))
	translation_input.z = int(Input.is_action_pressed("S")) - int(Input.is_action_pressed("W"))
	#translation_input = translation_input.normalized()
	
	if translation_input == Vector3.ZERO:
		if camera_velocity.length() > (friction * delta):
			camera_velocity -= camera_velocity.normalized() * (friction * delta)
		else:
			camera_velocity = Vector3.ZERO
	else:
		camera_velocity += (translation_input * accel * delta)
		camera_velocity = camera_velocity.limit_length(max_speed)
		
	
	
	#if Input.is_action_pressed("W"):
	#	camera_velocity.z -= camera_speed
	#if Input.is_action_pressed("S"):
	#	camera_velocity.z += camera_speed
	#if Input.is_action_pressed("D"):
	#	camera_velocity.x += camera_speed	
	#if Input.is_action_pressed("A"):
	#	camera_velocity.x -= camera_speed
	if Input.is_action_pressed("E"):
		camera_rotator.rotation_degrees.y += camera_rotation_speed * delta
	if Input.is_action_pressed("Q"):
		camera_rotator.rotation_degrees.y -= camera_rotation_speed * delta
	print(camera_rotator.rotation_degrees)
	camera_base.position += align_velocity_to_camera(camera_velocity) * delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)
	

func align_velocity_to_camera(velocity:Vector3):
	return velocity.rotated(Vector3(0,1,0),deg_to_rad(camera_rotator.rotation_degrees.y))
