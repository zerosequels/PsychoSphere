extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var cosmic_egg_controller = $cosmic_egg_controller
@onready var projectile = preload("res://scenes/galaxy_projectile.tscn")
@onready var emitter = $emitter

var should_hatch:bool = true
var time_to_hatch_ms = 10000
var last_hatch_time = 0
var egg_scale_ratio = 1.0

var base_damage = 1
var damage = base_damage

var emerald_tablet_stack_level = 0

var current_enemy_target = null
var has_target:bool = false

var base_multi_hit_proc_chance = 0.0
var multi_hit_proc_chance = 0.0

var able_to_hatch:bool = false

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.target_new_enemy.connect(_on_new_enemy_target)
	attack_area.targets_depleted.connect(_on_targets_depleted)
	last_hatch_time = Time.get_ticks_msec()

func _on_new_enemy_target(target):
	if target == null:
		current_enemy_target = null
		set_has_target(false)
		return
	current_enemy_target = target
	set_has_target(true)
	
func set_has_target(toggle:bool):
	has_target = toggle
	
func _on_targets_depleted():
	current_enemy_target = null
	set_has_target(false)
	
func _process(delta):
	if has_target and current_enemy_target != null:
		process_hatch_opportunity()
		egg_scale_ratio += delta
		set_egg_scale(egg_scale_ratio)
		if egg_scale_ratio >= 10.0:
			able_to_hatch = true
			egg_scale_ratio = 0

func set_egg_scale(egg_scale):
	cosmic_egg_controller.set_egg_scale(egg_scale)

func currently_able_to_hatch():
	if able_to_hatch:
		able_to_hatch = false
		return true
	else:
		return false


func process_hatch_opportunity():
	if currently_able_to_hatch():
		var galaxy = projectile.instantiate()
		galaxy.set_target(current_enemy_target)
		galaxy.set_damage(damage)
		galaxy.set_multi_hit_proc_chance(multi_hit_proc_chance)
		galaxy.set_homing_speed(2)
		emitter.add_child(galaxy)
		last_hatch_time = Time.get_ticks_msec()

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)


