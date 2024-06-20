extends Area3D

@onready var attack_radius_zone = $attack_radius_zone
@onready var attack_radius_indicator = $attack_radius_plane
@export var range = 5
var should_display_range_indicator:bool = false
var last_hovered = 0
var time_to_dim_ms = 550

var tween_opacity:Tween

var enemies_in_range = []
var range_vis_mode_enabled = false
var current_enemy = null

var is_aoe:bool = false

signal target_new_enemy(enemy)

func _ready():
	update_range(range)
	toggle_range_visibility_indicator(should_display_range_indicator)


func _process(delta):
	if Input.is_action_just_released("toggle_range_visibility_mode"):
		range_vis_mode_enabled = TowerAndBoonData.get_is_range_visibility_mode_toggled()
		toggle_range_visibility_indicator(TowerAndBoonData.get_is_range_visibility_mode_toggled())
			
	process_range_visibility_dim_opportunity()

func process_range_visibility_dim_opportunity():
	if range_vis_mode_enabled:
		return
	if Time.get_ticks_msec() > (last_hovered + time_to_dim_ms):
		toggle_range_visibility_indicator(false)

func update_range(new_range:float):
	range = new_range
	attack_radius_zone.shape.radius = range
	attack_radius_indicator.mesh.size = Vector2(range * 2,range * 2)

func toggle_range_visibility_indicator(should:bool):
	should_display_range_indicator = should
	if should:
		if tween_opacity and tween_opacity.is_running():
			tween_opacity.kill()
		tween_opacity = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_opacity.tween_property(attack_radius_indicator.get_surface_override_material(0), "shader_parameter/circle_opacity", 0.9, 0.1)
	else:
		if tween_opacity and tween_opacity.is_running():
			tween_opacity.kill()
		tween_opacity = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_opacity.tween_property(attack_radius_indicator.get_surface_override_material(0), "shader_parameter/circle_opacity", 0.0, 0.1)


func update_last_hovered():
	if range_vis_mode_enabled:
		return
	toggle_range_visibility_indicator(true)
	last_hovered = Time.get_ticks_msec()

func remove_enemy_from_array(area):
	if enemies_in_range.has(area):
		enemies_in_range.erase(area)

func _on_area_entered(area):
		#check if it's an enemy 
	if area.get_name() != "enemy_area":
		return
	if current_enemy == null:
		select_new_target(area)
	enemies_in_range.append(area)

func select_new_target(enemy):
	current_enemy = enemy
	emit_signal("target_new_enemy",enemy)

func _on_area_exited(area):
	if current_enemy == area:
		select_new_target(enemies_in_range.pick_random())
	remove_enemy_from_array(area)
