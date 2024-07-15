extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var aoe_plane = $turret_base/rotator/ankh_controller/aoe_locus/aoe_plane
var last_attack = 0
var base_time_to_attack_ms = 2500
var time_to_attack_ms = 2500
var base_radiant_damage = 1
var radiant_damage = 1
var tower_range = 5
var tunning_fork_stack_level = 0
var flower_of_life_stack_level = 0
var spiral_stack_level = 0
var base_multi_hit_proc_chance = 0.0
var multi_hit_proc_chance = 0.0

#this tower will attempt to damage all enemies within its range

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	update_tower_range(tower_range)
	radiant_damage = base_radiant_damage
	
func _process(delta):
	process_wave_damage_opportunity()

func update_tower_range(new_range:float):
	attack_area.update_range(new_range)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
	
func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	set_attack_speed_modifier(tunning_fork_stack_level)

func process_wave_damage_opportunity():
	if Time.get_ticks_msec() > (last_attack + time_to_attack_ms):
		var targets = attack_area.get_all_enemies_in_range()
		if targets.is_empty():
			return

		trigger_radiant_wave_damage(targets)
		last_attack = Time.get_ticks_msec()

func set_attack_speed_modifier(tunning_stack:int):
	time_to_attack_ms = base_time_to_attack_ms
	for x in tunning_stack:
		iterate_attack_speed_reduction()

func iterate_attack_speed_reduction():
	time_to_attack_ms -= (time_to_attack_ms * 0.10)

func trigger_radiant_wave_damage(targets):
	for enemy in targets:
		enemy.get_parent().get_parent().get_parent().take_damage(radiant_damage,multi_hit_proc_chance,Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)))

func increment_flower_of_life_buff(delta:int):
	flower_of_life_stack_level += delta
	set_multi_hit_proc_chance(flower_of_life_stack_level)

func set_multi_hit_proc_chance(fol_stack:int):
	multi_hit_proc_chance = base_multi_hit_proc_chance + 0.25
	for x in fol_stack:
		iterate_multi_hit_increase()

func iterate_multi_hit_increase():
	multi_hit_proc_chance += (multi_hit_proc_chance * 0.25)
	

func increment_spiral_buff(delta:int):
	spiral_stack_level += delta
	set_damage_modifier(spiral_stack_level)

func set_damage_modifier(spiral_stack:int):
	radiant_damage = base_radiant_damage
	for x in spiral_stack:
		iterate_damage_increase()


func iterate_damage_increase():
	radiant_damage += (radiant_damage * 0.15)



