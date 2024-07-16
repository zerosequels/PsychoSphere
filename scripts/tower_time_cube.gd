extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var aoe_plane = $aoeplane
var last_debuff = 0
var time_to_debuff_ms = 200
var tower_range = 5
var emerald_tablet_stack_level = 0

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	update_tower_range(tower_range)

func _process(delta):
	process_cubic_debuff_opportunity()

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func update_tower_range(new_range:float):
	attack_area.update_range(new_range)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)

func process_cubic_debuff_opportunity():
	if Time.get_ticks_msec() > (last_debuff + time_to_debuff_ms):
		var targets = attack_area.get_all_enemies_in_range()
		if targets.is_empty():
			return
		trigger_cubic_debuff(targets)
		last_debuff = Time.get_ticks_msec()

func trigger_cubic_debuff(targets):
	for enemy in targets:
		enemy.get_parent().get_parent().get_parent().apply_cubic_stack(1)
		
func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	var new_range = attack_area.set_range_modifier(emerald_tablet_stack_level)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)
	

