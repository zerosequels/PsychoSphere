extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var annunaki_controller = $annunaki_controller
@onready var beam = preload("res://scenes/annunaki_targeting_beam.tscn")

var annunaki_tower_base_range = 15
var emerald_tablet_stack_level = 0

var last_beam_completed = 0
var time_between_beams = 5000
var metero_hit_time = 2000

var is_beam_in_progress:bool = false

var beam_instance 


func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.update_base_range(annunaki_tower_base_range)

func _process(delta):
	process_meteor_opportunity()

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)

func process_meteor_opportunity():
	if is_beam_in_progress:
		return
	if Time.get_ticks_msec() > (last_beam_completed + time_between_beams):
		var targets = attack_area.get_all_enemies_in_range()
		if targets.is_empty():
			return
		var target = targets.pick_random()
		summon_beam(target)
		

func summon_beam(target):
	is_beam_in_progress = true
	beam_instance = beam.instantiate()
	beam_instance.set_target(target)
	beam_instance.request_new_target.connect(_on_request_new_target)
	beam_instance.beam_finished.connect(_on_beam_finished)
	add_child(beam_instance)
	
func _on_beam_finished():
	is_beam_in_progress = false
	beam_instance.queue_free()
	last_beam_completed = Time.get_ticks_msec()

func _on_request_new_target():
	if attack_area.get_all_enemies_in_range().is_empty():
		is_beam_in_progress = false
		beam_instance.queue_free()
		last_beam_completed = Time.get_ticks_msec()
	else:
		var target = attack_area.get_all_enemies_in_range().pick_random()
		beam_instance.set_target(target)
		
