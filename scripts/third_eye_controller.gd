extends Node3D

@onready var eye_rotator = $altar/third_eye_rotator
@onready var vision_cone = $altar/third_eye_rotator/vision_cone
@export var base_dot_speed_ms = 1.0
@export var dot_speed_ms = 1.0
@onready var pyramid = $altar/third_eye_pyramid

var last_dot_time = 0

var current_enemy_target: Node3D
var has_target:bool = false

var attack_opportunity_timer:Timer 

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
	elif !has_target:
		eye_rotator.rotation_degrees = Vector3(0,0,0)
		
func _ready():
	GameMode.update_game_speed.connect(_on_game_speed_updated)
	var starting_speed = GameMode.get_global_game_speed()
	attack_opportunity_timer = Timer.new()
	attack_opportunity_timer.one_shot = false
	attack_opportunity_timer.autostart = true
	attack_opportunity_timer.timeout.connect(process_attack_opportunity)
	attack_opportunity_timer.paused = false
	attack_opportunity_timer.wait_time = dot_speed_ms * (1/starting_speed)
	add_child(attack_opportunity_timer)
	dot_speed_ms = base_dot_speed_ms
	set_has_target(false)

func _on_game_speed_updated(game_speed):
	if game_speed == 0:
		attack_opportunity_timer.paused = true
		return
	attack_opportunity_timer.wait_time = dot_speed_ms * (1/game_speed)
	attack_opportunity_timer.paused = false
		
func look_at_enemy(enemy_pos:Vector3):
	eye_rotator.look_at(enemy_pos,Vector3(0,1,0))
	update_vision_cone(eye_rotator.global_position.distance_to(enemy_pos) * 2.0)

func process_attack_opportunity():
	if has_target and current_enemy_target != null:
		current_enemy_target.get_parent().get_parent().get_parent().apply_glowing_stack(1)
		last_dot_time = Time.get_ticks_msec()

func set_attack_speed_modifier(tunning_stack:int):
	dot_speed_ms = base_dot_speed_ms
	for x in tunning_stack:
		iterate_attack_speed_reduction()

func iterate_attack_speed_reduction():
	dot_speed_ms -= (dot_speed_ms * 0.10)
