extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var aoe_plane = $aoeplane

var emerald_tablet_stack_level = 0

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.enemy_died_in_radius.connect(_on_enemy_dies_in_fungus_radius)
	update_tower_range(attack_area.base_tower_range)

func _on_enemy_dies_in_fungus_radius(exp):
	TowerAndBoonData.increase_awarness(exp)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
	
func update_tower_range(new_range:float):
	attack_area.update_range(new_range)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)

func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	var new_range = attack_area.set_range_modifier(emerald_tablet_stack_level)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)
