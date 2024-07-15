extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.new_tower_entered_radius.connect(_on_tower_entered_radius)
	attack_area.set_is_support(true)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func _on_tower_entered_radius(tower_area):
	var tower = tower_area.get_parent()
	if tower.has_method("increment_spiral_buff"):
		tower.increment_spiral_buff(1)

func tower_removal_process():
	for tower in attack_area.get_all_towers_in_range():
		if tower.has_method("increment_spiral_buff"):
			tower.increment_spiral_buff(-1)
