extends Node3D

@onready var camera_target = %camera_boom
@onready var camera_base = %base
@onready var camera_rotator = %rotator

var camera_speed = 10 
var camera_rotation_speed = 100.0

var starting_position

var translation_input = Vector3.ZERO
var camera_velocity = Vector3.ZERO

var zoom_input:float

var zoom_min:float = 2
var zoom_max:float = 20
var zoom_value:float = 5
var zoom_speed:float = 0.2
var current_speed = 10
const max_speed = 10
const sprint_speed = 20
const accel = 75
const friction = 25

var is_camera_frozen:bool = false
var camera_is_dragging:bool = false

func _ready():
	starting_position = camera_base.position

func return_to_center():
	print("return to center")
	camera_base.position = starting_position

func get_input(delta):
	if Input.is_action_just_released("backspace"):
		return_to_center()
	if Input.is_action_just_pressed("middle_mouse"):
		camera_is_dragging = true
	if Input.is_action_just_released("middle_mouse"):
		camera_is_dragging = false
	if Input.is_action_just_pressed("shift"):
		current_speed = sprint_speed
	if Input.is_action_just_released("shift"):
		current_speed = max_speed
	
	if !is_camera_frozen:
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
			camera_velocity = camera_velocity.limit_length(current_speed)
			
		if Input.is_action_pressed("camera_zoom_in") or Input.is_action_just_released("camera_zoom_in"):
			zoom_value -= zoom_speed
			zoom_value = maxf(zoom_value,zoom_min)
		if Input.is_action_pressed("camera_zoom_out") or Input.is_action_just_released("camera_zoom_out"):
			zoom_value += zoom_speed
			zoom_value = minf(zoom_value,zoom_max)
		if Input.is_action_pressed("E"):
			camera_rotator.rotation_degrees.y += camera_rotation_speed * delta
		if Input.is_action_pressed("Q"):
			camera_rotator.rotation_degrees.y -= camera_rotation_speed * delta
		

		camera_base.position += align_velocity_to_camera(camera_velocity) * delta
		camera_target.position.y = zoom_value
		camera_target.position.z = zoom_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	get_input(delta)

func _input(event):
	if event is InputEventMouseMotion:
		#print(event.relative)
		if camera_is_dragging:
			camera_rotator.rotation_degrees.y -= (event.relative.x * zoom_value) / 25

func align_velocity_to_camera(velocity:Vector3):
	return velocity.rotated(Vector3(0,1,0),deg_to_rad(camera_rotator.rotation_degrees.y))

func toggle_is_camera_frozen(toggle:bool):
	is_camera_frozen = toggle
