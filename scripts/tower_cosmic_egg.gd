extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var cosmic_egg_controller = $cosmic_egg_controller
@onready var projectile = preload("res://scenes/cosmic_egg_projectile.tscn")
@onready var emitter = $emitter

var should_hatch:bool = true
var time_to_hatch_ms = 2
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

var tunning_fork_stack_level = 0
var base_egg_delta_threshold = 10.0
var egg_delta_threshold = 10.0
var flower_of_life_stack_level = 0
var spiral_stack_level = 0

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
	attack_opportunity_timer.timeout.connect(process_hatch_opportunity)
	attack_opportunity_timer.paused = false
	
	attack_opportunity_timer.wait_time = time_to_hatch_ms * (1/starting_speed)
	add_child(attack_opportunity_timer)
	
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.target_new_enemy.connect(_on_new_enemy_target)
	attack_area.targets_depleted.connect(_on_targets_depleted)
	last_hatch_time = Time.get_ticks_msec()
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)
	$buff_area.delta_spiral_buff.connect(increment_spiral_buff)
	$buff_area.delta_flower_of_life_buff.connect(increment_flower_of_life_buff)
	$buff_area.delta_tuning_buff.connect(increment_tunning_fork_buff)

func _on_game_speed_updated(game_speed):
	if game_speed == 0:
		attack_opportunity_timer.paused = true
		return
	attack_opportunity_timer.wait_time = time_to_hatch_ms * (1/game_speed)
	attack_opportunity_timer.paused = false

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,11)
		GlobalAudio.tower_removed_sfx()
		self.queue_free()

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

func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	set_attack_speed_modifier(tunning_fork_stack_level)

func set_attack_speed_modifier(tunning_stack:int):
	egg_delta_threshold = base_egg_delta_threshold
	for x in tunning_stack:
		iterate_attack_speed_reduction()

func iterate_attack_speed_reduction():
	egg_delta_threshold -= (egg_delta_threshold * 0.10)

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
	
func _process(delta):
	if has_target and current_enemy_target != null:
		egg_scale_ratio = attack_opportunity_timer.wait_time / (attack_opportunity_timer.wait_time - attack_opportunity_timer.time_left) 
		set_egg_scale(egg_scale_ratio)
	else:
		set_egg_scale(1)


func set_egg_scale(egg_scale):
	cosmic_egg_controller.set_egg_scale(egg_scale)

func currently_able_to_hatch():
	if able_to_hatch:
		able_to_hatch = false
		return true
	else:
		return false


func process_hatch_opportunity():
	if has_target and current_enemy_target != null:
		var galaxy = projectile.instantiate()
		galaxy.set_ricochet_number(3)
		galaxy.set_target(current_enemy_target)
		galaxy.set_damage(damage)
		galaxy.set_multi_hit_proc_chance(multi_hit_proc_chance)
		galaxy.set_homing_speed(2)
		emitter.add_child(galaxy)


func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)


