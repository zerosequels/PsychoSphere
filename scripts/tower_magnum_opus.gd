extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body

var emerald_tablet_stack_level = 0

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
	
func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)

