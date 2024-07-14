extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var turret_base = $turret_base
@onready var projectile = preload("res://scenes/projectile.tscn")

var enemies_in_range = []

var tunning_fork_stack_level = 0

func _ready():
	attack_area.target_new_enemy.connect($turret_base.set_current_enemy)
	attack_area.targets_depleted.connect(_on_targets_depleted)
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func _process(delta):
	pass

func update_range(new_range:float):
	attack_area.update_range(new_range)
	
func hover_by_raycast():
	attack_area.update_last_hovered()

func _on_targets_depleted():
	$turret_base.set_current_enemy(null)

func set_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	turret_base.set_attack_speed_modifier(tunning_fork_stack_level)

func get_tunning_fork_stack():
	return tunning_fork_stack_level 
	
	




