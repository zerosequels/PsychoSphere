extends Node3D

var targeting_cone
var rotational_axis_boom
var incline_axis_boom 
var meteor_projectile

var target
var homing_speed:float = 1.2
var is_target_locked:bool = false
var meteor_speed:float = 1.5

var laser_damage = 1.0
var multi_hit_proc_chance = 0.0
var time_to_hit_beam = 250
var last_hit_time_ms = 0
var laser_ammunition = 25

signal request_new_target()
signal beam_finished()

func set_beam_damage(new_damage):
	laser_damage = new_damage

func set_target(new_target):
	target = new_target
		
func _process(delta):
	if laser_ammunition == 0:
		emit_signal("beam_finished")
	if target != null:
		var direction_to_target = (target.global_position - global_position).normalized()
		#look_at(target.global_position, Vector3.UP)
		var new_position = global_position + direction_to_target * homing_speed * delta
		var distance_to_target = global_position.distance_to(target.global_position)
		global_translate(new_position - global_position)
		if distance_to_target < 0.2:
			if Time.get_ticks_msec() > (last_hit_time_ms + time_to_hit_beam):
				damage_enemy_with_laser()
				last_hit_time_ms = Time.get_ticks_msec()
	else:
		emit_signal("request_new_target")

func damage_enemy_with_laser():
	laser_ammunition -=1
	target.get_parent().get_parent().get_parent().take_damage(laser_damage,multi_hit_proc_chance,Vector3(0,0,0))

	
