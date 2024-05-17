extends Node3D

@onready var rotator = $base/rotator
@onready var turret = $base/rotator/turret
@onready var attack_radius_zone = $base/attack_area/attack_radius_zone
@onready var energy_beam = $base/rotator/turret/laser
#TODO: Make it so that this is visually indicated to the player when hovering over the tower
@export var range = 3
@export var attack_speed_ms = 1000
@export var damage = 1
var last_fire_time = 0


var current_enemy_target: Node3D
var has_target:bool = false

func _ready():
	update_range(range)

func _process(delta):
	if has_target and current_enemy_target != null:
		look_at_enemy(current_enemy_target.global_position)
		process_attack_opportunity()
	else:
		rotator.rotation_degrees = Vector3(0,0,0)


func process_attack_opportunity():
	if Time.get_ticks_msec() > (last_fire_time + attack_speed_ms):
		current_enemy_target.get_parent().get_parent().get_parent().take_damage(damage)
		last_fire_time = Time.get_ticks_msec()
	

func update_range(new_range:float):
	range = new_range
	attack_radius_zone.shape.radius = range

func look_at_enemy(enemy_pos:Vector3):
	rotator.look_at(enemy_pos + Vector3(0.5,0.5,0.5),Vector3(0,0,1))
	
	#print(enemy_pos)

func set_has_target(has_a_target:bool):
	if has_a_target:
		turret.rotation_degrees = Vector3(90,180,0)
		energy_beam.set_is_firing(true)
		energy_beam.set_laser_target(current_enemy_target)
		#set rotation of the rotator to look forward
	else:
		turret.rotation_degrees = Vector3(0,180,0)
		energy_beam.set_is_firing(false)
		#energy_beam.set_laser_target(null)
		#reset rotation on the rotator to face up.
	has_target = has_a_target


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
		print("current enemy has left")
		set_has_target(false)
		current_enemy_target = null
