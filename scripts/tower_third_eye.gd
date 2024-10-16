extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var third_eye_controller = $third_eye_controller
var type_id = 1
var tunning_fork_stack_level = 0
var emerald_tablet_stack_level = 0

var price:int = 0

func set_tower_price(cost:int):
	price = cost

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.target_new_enemy.connect(_on_retarget)
	attack_area.targets_depleted.connect(_on_targets_depleted)
	third_eye_controller.update_vision_cone(attack_area.tower_range)
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,1)
		GlobalAudio.tower_removed_sfx()
		self.queue_free()

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
func _on_retarget(enemy):
	#print("on retarget")
	third_eye_controller.set_current_enemy(enemy)
func _on_targets_depleted():
	#print("on targets depleted")
	third_eye_controller.set_current_enemy(null)
	
func increment_tunning_fork_buff(delta:int):
	tunning_fork_stack_level += delta
	third_eye_controller.set_attack_speed_modifier(tunning_fork_stack_level)

func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	var new_range = attack_area.set_range_modifier(emerald_tablet_stack_level)
	

