extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var magnum_opus = $magnum_opus

@onready var projectile = preload("res://scenes/sun_ray_projectile.tscn")
var type_id = 10
var emerald_tablet_stack_level = 0
var base_attack_speed_ms = 1
var attack_speed_ms = 1
var damage:float = 0
var damage_base:float = 1

var base_multi_hit_proc_chance = 0.0
var multi_hit_proc_chance = 0.0

var tunning_fork_stack_level = 0
var spiral_stack_level = 0
var flower_of_life_stack_level = 0

var current_enemy_target: Node3D
var has_target:bool = false

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
	attack_opportunity_timer.timeout.connect(process_attack_opportunity)
	attack_opportunity_timer.paused = false
	attack_opportunity_timer.wait_time = attack_speed_ms * (1/starting_speed)
	add_child(attack_opportunity_timer)
	
	#attack_area.target_new_enemy.connect(_on_target_new_enemy)
	#attack_area.targets_depleted.connect(_on_targets_depleted)
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)
	$buff_area.delta_spiral_buff.connect(increment_spiral_buff)
	$buff_area.delta_flower_of_life_buff.connect(increment_flower_of_life_buff)
	$buff_area.delta_tuning_buff.connect(increment_tunning_fork_buff)

func _on_game_speed_updated(game_speed):
	if game_speed == 0:
		attack_opportunity_timer.paused = true
		return
	attack_opportunity_timer.wait_time = attack_speed_ms * (1/game_speed)
	attack_opportunity_timer.paused = false

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,10)
		GlobalAudio.tower_removed_sfx()
		self.queue_free()



func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
	
func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)

func process_attack_opportunity():
	for enemy in attack_area.get_all_enemies_in_range():
		var bullet = projectile.instantiate()
		bullet.set_target(enemy)
		bullet.set_damage(damage)
		bullet.set_multi_hit_proc_chance(multi_hit_proc_chance)
		bullet.set_magnum_opus_stack(1)
		magnum_opus.add_child(bullet)


func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	set_attack_speed_modifier(tunning_fork_stack_level)

func set_attack_speed_modifier(tunning_stack:int):
	attack_speed_ms = base_attack_speed_ms
	for x in tunning_stack:
		iterate_attack_speed_reduction()

func iterate_attack_speed_reduction():
	attack_speed_ms -= (attack_speed_ms * 0.10)

func increment_spiral_buff(delta:int):
	spiral_stack_level += delta
	set_damage_modifier(spiral_stack_level)

func set_damage_modifier(spiral_stack:int):
	damage = damage_base
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

func _on_target_new_enemy():
	pass

func _on_targets_depleted():
	pass
