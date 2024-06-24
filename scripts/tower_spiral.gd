extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

