extends Area3D

@onready var attack_radius_zone = $attack_radius_zone
@onready var attack_radius_indicator = $attack_radius_plane

var should_display_range_indicator:bool = false
var last_hovered = 0
var time_to_dim_ms = 550

var tween_opacity:Tween

var enemies_in_range = []
var towers_in_range = []
var range_vis_mode_enabled = false
var current_enemy = null

var is_support:bool = false
var is_aoe:bool = false

signal target_new_enemy(enemy)
signal targets_depleted()
signal enemy_died_in_radius(exp)
signal new_tower_entered_radius(area)

func _ready():
	print(get_instance_id())
	create_cylinder_shape()
	print(attack_radius_zone.shape)
	range_vis_mode_enabled = TowerAndBoonData.get_is_range_visibility_mode_toggled()
	should_display_range_indicator = range_vis_mode_enabled
	toggle_range_visibility_indicator(should_display_range_indicator)

func create_cylinder_shape():
	var attack_shape = CylinderShape3D.new()
	attack_shape.height = 1
	attack_shape.radius = 5
	attack_shape.margin = 0.04
	attack_shape.set_local_to_scene(true)
	attack_radius_zone.shape = attack_shape

func _process(delta):
	if Input.is_action_just_released("toggle_range_visibility_mode"):
		range_vis_mode_enabled = TowerAndBoonData.get_is_range_visibility_mode_toggled()
		toggle_range_visibility_indicator(TowerAndBoonData.get_is_range_visibility_mode_toggled())
	process_range_visibility_dim_opportunity()
	process_retargeting_opportunity()

func set_is_support(toggle:bool):
	is_support = toggle

func process_retargeting_opportunity():
	if enemies_in_range.size() == 0:
		#print("we are out of enemies sir")
		return
	elif current_enemy != null:
		return
	#print("retarget")
	select_new_target(enemies_in_range.front())
	

func process_range_visibility_dim_opportunity():
	if range_vis_mode_enabled:
		return
	if Time.get_ticks_msec() > (last_hovered + time_to_dim_ms):
		toggle_range_visibility_indicator(false)

func update_range(new_range:float):
	attack_radius_zone.shape.radius = new_range
	attack_radius_indicator.mesh.size = Vector2(new_range * 2,new_range * 2)

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
		if area.get_name() == "attack_area" and is_support:
			towers_in_range.append(area)
			emit_signal("new_tower_entered_radius",area)
		return
	if current_enemy == null:
		select_new_target(area)
	enemies_in_range.append(area)
	area.get_parent().get_parent().get_parent().connect("enemy_killed", _on_enemy_in_radius_killed)

func _on_enemy_in_radius_killed(exp:int, enemy_uuid:int):
	emit_signal("enemy_died_in_radius",exp)

func select_new_target(enemy):
	if enemy == null:
		current_enemy = null
		return
	current_enemy = enemy
	emit_signal("target_new_enemy",enemy)

func _on_area_exited(area):
	if area.get_name() != "enemy_area":
		if area.get_name() == "attack_area" and is_support:
			if towers_in_range.has(area):
				towers_in_range.erase(area)
		return
	remove_enemy_from_array(area)
	if current_enemy == area:
		current_enemy = null
		if enemies_in_range.size() == 0:
			emit_signal("targets_depleted")
		else:	
			select_new_target(enemies_in_range.pick_random())
	#print("_on_area_exited")
	area.get_parent().get_parent().get_parent().disconnect("enemy_killed", _on_enemy_in_radius_killed)

func get_all_enemies_in_range():
	return enemies_in_range.duplicate(true)

func get_all_towers_in_range():
	return towers_in_range.duplicate(true)

