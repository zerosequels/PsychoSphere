extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var aoe_plane = $aoeplane
var tower_range = 5

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.enemy_died_in_radius.connect(_on_enemy_dies_in_fungus_radius)
	update_tower_range(tower_range)

func _on_enemy_dies_in_fungus_radius(exp):
	TowerAndBoonData.increase_awarness(exp)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
	
func update_tower_range(new_range:float):
	attack_area.update_range(new_range)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)

