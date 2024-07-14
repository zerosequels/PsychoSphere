extends MeshInstance3D
@onready var turret = $rotator/turret
@onready var rotator = $rotator
@export var base_attack_speed_ms = 1000
@export var attack_speed_ms = 1000
@export var damage:float = 1
var last_fire_time = 0

var current_enemy_target: Node3D
var has_target:bool = false

@onready var projectile = preload("res://scenes/projectile.tscn")

func _ready():
	attack_speed_ms = base_attack_speed_ms

func set_attack_speed_modifier(tunning_stack:int):
	attack_speed_ms = base_attack_speed_ms
	for x in tunning_stack:
		iterate_attack_speed_reduction()

func iterate_attack_speed_reduction():
	attack_speed_ms -= (attack_speed_ms * 0.10)
	

func set_current_enemy(target):
	if target == null:
		current_enemy_target = null
		set_has_target(false)
		#print("target is null")
		return
	current_enemy_target = target
	set_has_target(true)

func set_has_target(has_a_target:bool):
	if has_a_target:
		turret.rotation_degrees = Vector3(90,180,0)
		#set rotation of the rotator to look forward
	else:
		turret.rotation_degrees = Vector3(0,180,0)

	has_target = has_a_target
	
func _process(delta):

	if has_target and current_enemy_target != null:
		look_at_enemy(current_enemy_target.global_position)
		process_attack_opportunity()
	else:
		rotator.rotation_degrees = Vector3(0,0,0)
		set_has_target(false)


func look_at_enemy(enemy_pos:Vector3):
	rotator.look_at(enemy_pos,Vector3(0,1,0))

func process_attack_opportunity():
	if Time.get_ticks_msec() > (last_fire_time + attack_speed_ms):
		var bullet = projectile.instantiate()
		bullet.set_target(current_enemy_target)
		bullet.set_damage(damage)
		$rotator/turret/bullet_locus.add_child(bullet)
		last_fire_time = Time.get_ticks_msec()
	


