extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var annunaki_controller = $annunaki_controller
@onready var beam = preload("res://scenes/annunaki_targeting_beam.tscn")
var type_id = 12
var annunaki_tower_base_range = 15
var emerald_tablet_stack_level = 0

var base_time_between_beams = 5
var time_between_beams = 5

var base_damage = 1
var damage = 1

var is_beam_in_progress:bool = false

var beam_instance 

var tunning_fork_stack_level = 0
var spiral_stack_level = 0
var flower_of_life_stack_level = 0

var multi_hit_proc_chance = 0
var base_multi_hit_proc_chance = 0

var price:int = 0

var attack_opportunity_timer:Timer 

func set_tower_price(cost:int):
	price = cost

func _ready():
	GameMode.update_game_speed.connect(_on_game_speed_updated)
	var starting_speed = GameMode.get_global_game_speed()
	attack_opportunity_timer = Timer.new()
	attack_opportunity_timer.one_shot = false
	attack_opportunity_timer.autostart = true
	attack_opportunity_timer.timeout.connect(process_meteor_opportunity)
	attack_opportunity_timer.paused = false
	attack_opportunity_timer.wait_time = time_between_beams * (1/starting_speed)
	add_child(attack_opportunity_timer)
	
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.update_range(annunaki_tower_base_range)
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)
	$buff_area.delta_spiral_buff.connect(increment_spiral_buff)
	$buff_area.delta_flower_of_life_buff.connect(increment_flower_of_life_buff)
	$buff_area.delta_tuning_buff.connect(increment_tunning_fork_buff)

func _on_game_speed_updated(game_speed):
	if game_speed == 0:
		attack_opportunity_timer.paused = true
		return
	attack_opportunity_timer.wait_time = time_between_beams * (1/game_speed)
	attack_opportunity_timer.paused = false

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,type_id)
		GlobalAudio.tower_removed_sfx()
		self.queue_free()


func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)

func process_meteor_opportunity():
	if is_beam_in_progress:
		return
	var targets = attack_area.get_all_enemies_in_range()
	if targets.is_empty():
		return
	var target = targets.pick_random()
	summon_beam(target)

func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	set_attack_speed_modifier(tunning_fork_stack_level)

func set_attack_speed_modifier(tunning_stack:int):
	time_between_beams = base_time_between_beams
	for x in tunning_stack:
		iterate_attack_speed_reduction()

func iterate_attack_speed_reduction():
	time_between_beams -= (time_between_beams * 0.10)

func increment_spiral_buff(delta:int):
	spiral_stack_level += delta
	set_damage_modifier(spiral_stack_level)

func set_damage_modifier(spiral_stack:int):
	damage = base_damage
	for x in spiral_stack:
		iterate_damage_increase()

func iterate_damage_increase():
	damage += (damage * 0.15)

func increment_flower_of_life_buff(delta:int):
	flower_of_life_stack_level += delta
	set_multi_hit_proc_chance(flower_of_life_stack_level)

func set_multi_hit_proc_chance(fol_stack:int):
	multi_hit_proc_chance = base_multi_hit_proc_chance + 0.25
	for x in fol_stack:
		iterate_multi_hit_increase()

func iterate_multi_hit_increase():
	multi_hit_proc_chance += (multi_hit_proc_chance * 0.25)

func summon_beam(target):
	is_beam_in_progress = true
	beam_instance = beam.instantiate()
	beam_instance.set_target(target)
	beam_instance.set_beam_damage(damage)
	beam_instance.request_new_target.connect(_on_request_new_target)
	beam_instance.beam_finished.connect(_on_beam_finished)
	add_child(beam_instance)
	
func _on_beam_finished():
	is_beam_in_progress = false
	beam_instance.queue_free()


func _on_request_new_target():
	if attack_area.get_all_enemies_in_range().is_empty():
		is_beam_in_progress = false
		beam_instance.queue_free()

	else:
		var target = attack_area.get_all_enemies_in_range().pick_random()
		beam_instance.set_target(target)
		
