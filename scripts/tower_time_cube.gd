extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var aoe_plane = $aoeplane
var type_id = 7
var last_debuff = 0
var time_to_debuff_ms = 0.2
var tower_range = 5
var emerald_tablet_stack_level = 0

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
	attack_opportunity_timer.timeout.connect(process_cubic_debuff_opportunity)
	attack_opportunity_timer.paused = false
	attack_opportunity_timer.wait_time = time_to_debuff_ms * (1/starting_speed)
	add_child(attack_opportunity_timer)
	
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	update_tower_range(tower_range)
	mouse_detector.tower_clicked.connect(_on_clicked)
	$buff_area.delta_emerald_tablet_buff.connect(increment_emerald_tablet_buff)

func _on_game_speed_updated(game_speed):
	if game_speed == 0:
		attack_opportunity_timer.paused = true
		return
	attack_opportunity_timer.wait_time = time_to_debuff_ms * (1/game_speed)
	attack_opportunity_timer.paused = false

func _on_clicked():
	#check if player is in sell mode. 
	if TowerAndBoonData.get_currently_selected_tower() == 13:
		TowerAndBoonData.refund_tower_by_price_and_type(price,7)
		GlobalAudio.tower_removed_sfx()
		self.queue_free()


func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func update_tower_range(new_range:float):
	attack_area.update_range(new_range)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)

func process_cubic_debuff_opportunity():
	var targets = attack_area.get_all_enemies_in_range()
	if targets.is_empty():
		return
	trigger_cubic_debuff(targets)


func trigger_cubic_debuff(targets):
	for enemy in targets:
		enemy.get_parent().get_parent().get_parent().apply_cubic_stack(1)
		
func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	var new_range = attack_area.set_range_modifier(emerald_tablet_stack_level)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)
	

