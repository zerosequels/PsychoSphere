extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var aoe_plane = $turret_base/rotator/ankh_controller/aoe_locus/aoe_plane
var last_attack = 0
var time_to_attack_ms = 2500
var radiant_damage = 1
var tower_range = 5

#this tower will attempt to damage all enemies within its range

func _ready():
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)
	update_tower_range(tower_range)
	
func _process(delta):
	process_wave_damage_opportunity()

func update_tower_range(new_range:float):
	attack_area.update_range(new_range)
	aoe_plane.scale = Vector3(new_range,new_range,new_range)

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()

func process_wave_damage_opportunity():
	if Time.get_ticks_msec() > (last_attack + time_to_attack_ms):
		var targets = attack_area.get_all_enemies_in_range()
		if targets.is_empty():
			return

		trigger_radiant_wave_damage(targets)
		last_attack = Time.get_ticks_msec()
		

func trigger_radiant_wave_damage(targets):
	for enemy in targets:
		enemy.get_parent().get_parent().get_parent().take_damage(radiant_damage,Vector3(randf_range(-1,1),randf_range(-1,1),randf_range(-1,1)))


	


