extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
var type_id = 5
var price:int = 0

func set_tower_price(cost:int):
	price = cost

func _ready():
	attack_area.set_attack_radius_zone_depth(-5.0)
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	attack_area.new_tower_entered_radius.connect(_on_tower_entered_radius)
	attack_area.set_is_support(true)
	mouse_detector.tower_clicked.connect(_on_clicked)

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,5)
		GlobalAudio.tower_removed_sfx()
		tower_removal_process()
		self.queue_free()
	
func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func _on_tower_entered_radius(tower_area):
	if tower_area.has_method("increment_emerald_tablet_buff"):
		tower_area.increment_emerald_tablet_buff()

func tower_removal_process():
	for tower in attack_area.get_all_towers_in_range():
		if tower.has_method("deincrement_emerald_tablet_buff"):
			tower.deincrement_emerald_tablet_buff()


