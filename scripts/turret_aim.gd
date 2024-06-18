extends Node3D

@onready var rotator = $base/rotator
@onready var turret = $base/rotator/turret
@onready var attack_radius_zone = $base/attack_area/attack_radius_zone
@onready var attack_radius_indicator = $base/attack_area/attack_radius_plane
@onready var mouse_detector_zone = $base/mouse_area
@onready var projectile = preload("res://scenes/projectile.tscn")

#TODO: Make it so that this is visually indicated to the player when hovering over the tower
@export var range = 5
@export var attack_speed_ms = 1000
@export var damage = 1
var last_fire_time = 0
var should_display_range_indicator:bool = false


var current_enemy_target: Node3D
var has_target:bool = false
var last_hovered = 0
var time_to_dim_ms = 550

func _ready():
	mouse_detector_zone.position.y += 0.01
	toggle_range_visibility_indicator(should_display_range_indicator)
	update_range(range)

func _process(delta):
	process_range_visibility_dim_opportunity()
	if has_target and current_enemy_target != null:
		look_at_enemy(current_enemy_target.global_position)
		process_attack_opportunity()
	else:
		rotator.rotation_degrees = Vector3(0,0,0)

func process_range_visibility_dim_opportunity():
	if Time.get_ticks_msec() > (last_hovered + time_to_dim_ms):
		toggle_range_visibility_indicator(false)

func toggle_range_visibility_indicator(should:bool):
	should_display_range_indicator = should
	attack_radius_indicator.visible = should_display_range_indicator

func update_last_hovered():
	toggle_range_visibility_indicator(true)
	last_hovered = Time.get_ticks_msec()

func process_attack_opportunity():
	if Time.get_ticks_msec() > (last_fire_time + attack_speed_ms):
		#current_enemy_target.get_parent().get_parent().get_parent().take_damage(damage)
		#instantiate a projectile that will then home to the target
		var bullet = projectile.instantiate()
		bullet.set_target(current_enemy_target)
		bullet.set_damage(damage)
		$base/bullet_locus.add_child(bullet)
		last_fire_time = Time.get_ticks_msec()
	

func update_range(new_range:float):
	range = new_range
	attack_radius_zone.shape.radius = range
	attack_radius_indicator.mesh.size = Vector2(range * 2,range * 2)

func look_at_enemy(enemy_pos:Vector3):
	rotator.look_at(enemy_pos + Vector3(0.0,0.0,0.0),Vector3(0,0,1))
	
	#print(enemy_pos)

func set_has_target(has_a_target:bool):
	if has_a_target:
		turret.rotation_degrees = Vector3(90,180,0)
		#set rotation of the rotator to look forward
	else:
		turret.rotation_degrees = Vector3(0,180,0)

	has_target = has_a_target

#TODO: once an enemy is dead, you need to check if there are still enemies there or not,
#add entered enemies to a list of available targets and select the next one 
#if they are still there
func _on_attack_area_area_entered(area):
	#check if it's an enemy 
	if area.get_name() != "enemy_area":
		return
	#check if you have a target and if not set this as the current target
	if has_target == false:
		current_enemy_target = area
		set_has_target(true)


func _on_attack_area_area_exited(area):
	if current_enemy_target == area:
		set_has_target(false)
		current_enemy_target = null

