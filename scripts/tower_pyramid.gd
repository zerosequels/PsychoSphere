extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var turret_base = $turret_base

var type_id = 0
var enemies_in_range = []

var tunning_fork_stack_level = 0
var flower_of_life_stack_level = 0
var spiral_stack_level = 0
var emerald_tablet_stack_level = 0
var tower_range :float = 5
var base_tower_range:float = 5

var price:int = 0

func set_tower_price(cost:int):
	price = cost


func _ready():
	
	attack_area.target_new_enemy.connect($turret_base.set_current_enemy)
	attack_area.targets_depleted.connect(_on_targets_depleted)
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)
	$buff_area.delta_spiral_buff.connect(increment_spiral_buff)
	$buff_area.delta_flower_of_life_buff.connect(increment_flower_of_life_buff)
	$buff_area.delta_tuning_buff.connect(increment_tunning_fork_buff)

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,0)
		GlobalAudio.tower_removed_sfx()
		self.queue_free()
		

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func update_range(new_range:float):
	attack_area.update_range(new_range)
	
func hover_by_raycast():
	attack_area.update_last_hovered()

func _on_targets_depleted():
	$turret_base.set_current_enemy(null)

func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	turret_base.set_attack_speed_modifier(tunning_fork_stack_level)

func get_tunning_fork_stack():
	return tunning_fork_stack_level 

func increment_flower_of_life_buff(delta:int):
	flower_of_life_stack_level += delta
	turret_base.set_multi_hit_proc_chance(flower_of_life_stack_level)

func increment_spiral_buff(delta:int):
	spiral_stack_level += delta
	turret_base.set_damage_modifier(spiral_stack_level)

func get_flower_of_life_stack():
	return flower_of_life_stack_level 

func get_spiral_stack():
	return spiral_stack_level 
	
func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)



