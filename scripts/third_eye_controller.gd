extends Node3D

@onready var eye_rotator = $altar/third_eye_rotator
@onready var vision_cone = $altar/third_eye_rotator/vision_cone
@export var base_dot_speed_ms = 1000
@export var dot_speed_ms = 1000
@onready var pyramid = $altar/third_eye_pyramid

var last_dot_time = 0

var current_enemy_target: Node3D
var has_target:bool = false

func update_vision_cone(range:float):
	vision_cone.position.z = range/2 * -1
	vision_cone.scale.y = range/2

func set_current_enemy(target):
	
	if target == null:
		current_enemy_target = null
		set_has_target(false)
		return
	current_enemy_target = target
	set_has_target(true)

func set_has_target(has_a_target:bool):
	if has_a_target:
		#change the color of the eye
		vision_cone.visible = true
	else:
		#change the color of the eye back to normal
		vision_cone.visible = false

	has_target = has_a_target
	
func _process(delta):

	if has_target and current_enemy_target != null:
		look_at_enemy(current_enemy_target.global_position)
		process_attack_opportunity()
	elif !has_target:
		eye_rotator.rotation_degrees = Vector3(0,0,0)
		
func _ready():
	dot_speed_ms = base_dot_speed_ms
	set_has_target(false)
		
func look_at_enemy(enemy_pos:Vector3):
	eye_rotator.look_at(enemy_pos,Vector3(0,1,0))
	update_vision_cone(eye_rotator.global_position.distance_to(enemy_pos) * 2.0)

func process_attack_opportunity():
	if Time.get_ticks_msec() > (last_dot_time + dot_speed_ms):
		current_enemy_target.get_parent().get_parent().get_parent().apply_glowing_stack(1)
		last_dot_time = Time.get_ticks_msec()

func set_attack_speed_modifier(tunning_stack:int):
	dot_speed_ms = base_dot_speed_ms
	for x in tunning_stack:
		iterate_attack_speed_reduction()

func iterate_attack_speed_reduction():
	dot_speed_ms -= (dot_speed_ms * 0.10)
