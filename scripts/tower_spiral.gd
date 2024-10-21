extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
var type_id = 3

var emerald_tablet_stack_level = 0

var price:int = 0

func set_tower_price(cost:int):
	price = cost

func _ready():
	attack_area.set_attack_radius_zone_depth(-5.0)
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.new_tower_entered_radius.connect(_on_tower_entered_radius)
	attack_area.set_is_support(true)
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,3)
		GlobalAudio.tower_removed_sfx()
		tower_removal_process()
		self.queue_free()

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	var new_range = attack_area.set_range_modifier(emerald_tablet_stack_level)

func _on_tower_entered_radius(tower_area):
	if tower_area.has_method("increment_spiral_buff"):
		tower_area.increment_spiral_buff()

func tower_removal_process():
	for tower in attack_area.get_all_towers_in_range():
		if tower.has_method("deincrement_spiral_buff"):
			tower.deincrement_spiral_buff()
