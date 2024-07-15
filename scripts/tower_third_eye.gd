extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var third_eye_controller = $third_eye_controller

var tunning_fork_stack_level = 0

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.target_new_enemy.connect(_on_retarget)
	attack_area.targets_depleted.connect(_on_targets_depleted)
	third_eye_controller.update_vision_cone(attack_area.range)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
func _on_retarget(enemy):
	#print("on retarget")
	third_eye_controller.set_current_enemy(enemy)
func _on_targets_depleted():
	#print("on targets depleted")
	third_eye_controller.set_current_enemy(null)
	
func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	third_eye_controller.set_attack_speed_modifier(tunning_fork_stack_level)


