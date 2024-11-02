extends MeshInstance3D
@onready var turret = $rotator/turret
@onready var rotator = $rotator
@export var base_attack_speed_ms = 1.0
@export var attack_speed_ms = 1.0
@export var damage:float = 1
@export var damage_base:float = 1
var last_fire_time = 0
var base_multi_hit_proc_chance = 0.0
var multi_hit_proc_chance = 0.0

var current_enemy_target: Node3D
var has_target:bool = false

@onready var projectile = preload("res://scenes/projectile.tscn")

var attack_opportunity_timer:Timer 

func _ready():
	GameMode.update_game_speed.connect(_on_game_speed_updated)
	var starting_speed = GameMode.get_global_game_speed()
	attack_opportunity_timer = Timer.new()
	attack_opportunity_timer.one_shot = false
	attack_opportunity_timer.autostart = true
	attack_opportunity_timer.timeout.connect(process_attack_opportunity)
	attack_opportunity_timer.paused = false
	attack_opportunity_timer.wait_time = attack_speed_ms * (1/starting_speed)
	add_child(attack_opportunity_timer)
	
	attack_speed_ms = base_attack_speed_ms
	damage = damage_base

func _on_game_speed_updated(game_speed):
	if game_speed == 0:
		attack_opportunity_timer.paused = true
		return
	attack_opportunity_timer.wait_time = attack_speed_ms * (1/game_speed)
	attack_opportunity_timer.paused = false

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
	else:
		rotator.rotation_degrees = Vector3(0,0,0)
		set_has_target(false)


func look_at_enemy(enemy_pos:Vector3):
	rotator.look_at(enemy_pos,Vector3(0,1,0))

func process_attack_opportunity():
	if has_target and current_enemy_target != null:
		var bullet = projectile.instantiate()
		bullet.set_target(current_enemy_target)
		bullet.set_damage(damage)
		bullet.set_multi_hit_proc_chance(multi_hit_proc_chance)
		$rotator/turret/bullet_locus.add_child(bullet)
	
func set_damage_modifier(fol_stack:int):
	damage = damage_base
	for x in fol_stack:
		iterate_damage_increase()


func iterate_damage_increase():
	damage += (damage * 0.15)


func set_multi_hit_proc_chance(fol_stack:int):
	multi_hit_proc_chance = base_multi_hit_proc_chance + 0.25
	for x in fol_stack:
		iterate_multi_hit_increase()


func iterate_multi_hit_increase():
	multi_hit_proc_chance += (multi_hit_proc_chance * 0.25)


	


