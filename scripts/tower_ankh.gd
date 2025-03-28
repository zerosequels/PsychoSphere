extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var aoe_plane = $turret_base/rotator/ankh_controller/aoe_locus/aoe_plane


var type_id = 2
var last_attack = 0
var base_time_to_attack = 2.5
var time_to_attack = 2.5
var base_radiant_damage = 1
var radiant_damage = 1
var tower_range = 5
var tunning_fork_stack_level = 0
var flower_of_life_stack_level = 0
var spiral_stack_level = 0
var base_multi_hit_proc_chance = 0.0
var multi_hit_proc_chance = 0.0
var emerald_tablet_stack_level = 0

var attack_opportunity_timer:Timer 

#this tower will attempt to damage all enemies within its range

var price:int = 0

func set_tower_price(cost:int):
	price = cost

func _ready():
	GameMode.update_game_speed.connect(_on_game_speed_updated)
	var starting_speed = GameMode.get_global_game_speed()
	attack_opportunity_timer = Timer.new()
	attack_opportunity_timer.one_shot = false
	attack_opportunity_timer.autostart = true
	attack_opportunity_timer.timeout.connect(process_wave_damage_opportunity)
	attack_opportunity_timer.paused = false
	attack_opportunity_timer.wait_time = time_to_attack * (1/starting_speed)
	add_child(attack_opportunity_timer)
	
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	update_tower_range(tower_range)
	radiant_damage = base_radiant_damage
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)
	$buff_area.delta_spiral_buff.connect(increment_spiral_buff)
	$buff_area.delta_flower_of_life_buff.connect(increment_flower_of_life_buff)
	$buff_area.delta_tuning_buff.connect(increment_tunning_fork_buff)

func _on_game_speed_updated(game_speed):
	if game_speed == 0:
		attack_opportunity_timer.paused = true
		return
	attack_opportunity_timer.wait_time = time_to_attack * (1/game_speed)
	attack_opportunity_timer.paused = false

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,2)
		GlobalAudio.tower_removed_sfx()
		self.queue_free()
	

func update_tower_range(new_range:float):
	attack_area.update_range(new_range)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
	
func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	set_attack_speed_modifier(tunning_fork_stack_level)

func process_wave_damage_opportunity():
	var targets = attack_area.get_all_enemies_in_range()
	if targets.is_empty():
		return
	trigger_radiant_wave_damage(targets)
	print("ankh attack")
	print(attack_opportunity_timer.wait_time)


func set_attack_speed_modifier(tunning_stack:int):
	time_to_attack = base_time_to_attack
	for x in tunning_stack:
		iterate_attack_speed_reduction()
	attack_opportunity_timer.wait_time = time_to_attack

func iterate_attack_speed_reduction():
	time_to_attack -= (time_to_attack * 0.10)

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
	
func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	var new_range = attack_area.set_range_modifier(emerald_tablet_stack_level)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)




