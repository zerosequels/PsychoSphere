extends Node3D

@onready var attack_area = $attack_area
@onready var mouse_detector = $static_mouse_detection_body
@onready var magnum_opus = $magnum_opus

@onready var projectile = preload("res://scenes/sun_ray_projectile.tscn")

var emerald_tablet_stack_level = 0
var base_attack_speed_ms = 1000
var attack_speed_ms = 1000
var damage:float = 0
var damage_base:float = 1
var last_fire_time = 0
var base_multi_hit_proc_chance = 0.0
var multi_hit_proc_chance = 0.0

var current_enemy_target: Node3D
var has_target:bool = false

func _ready():
	#attack_area.target_new_enemy.connect(_on_target_new_enemy)
	#attack_area.targets_depleted.connect(_on_targets_depleted)
	mouse_detector.mouse_detector_hovered.connect(_on_mouse_detector_hovered)

func _process(delta):
	process_attack_opportunity()

func _on_mouse_detector_hovered():
	attack_area.update_last_hovered()
	
func increment_emerald_tablet_buff(delta:int):
	emerald_tablet_stack_level += delta
	attack_area.set_range_modifier(emerald_tablet_stack_level)

func process_attack_opportunity():
	if Time.get_ticks_msec() > (last_fire_time + attack_speed_ms):
		for enemy in attack_area.get_all_enemies_in_range():
			var bullet = projectile.instantiate()
			bullet.set_target(enemy)
			bullet.set_damage(damage)
			bullet.set_multi_hit_proc_chance(multi_hit_proc_chance)
			magnum_opus.add_child(bullet)
		last_fire_time = Time.get_ticks_msec()

func _on_target_new_enemy():
	pass

func _on_targets_depleted():
	pass
