extends Node3D

var target:Node3D
var homing_speed:float = 10
var damage = 0
var multi_hit_proc_chance = 0.0
var magnum_opus_stack_on_hit = 0

func set_magnum_opus_stack(stack_count):
	magnum_opus_stack_on_hit = stack_count

func set_homing_speed(new_speed):
	homing_speed = new_speed
	
func set_target(new_target:Node3D):
	target = new_target
	
func set_damage(damage_value:int):
	damage = damage_value
	
func set_multi_hit_proc_chance(chance:float):
	multi_hit_proc_chance = chance
	
func set_starting_position(new_position):
	global_position = new_position


func _process(delta):
	if target != null:
		var direction_to_target = (target.global_position - global_position).normalized()
		look_at(target.global_position, Vector3.UP)
		var new_position = global_position + direction_to_target * homing_speed * delta
		var distance_to_target = global_position.distance_to(target.global_position)
		global_translate(new_position - global_position)
		if distance_to_target < 0.2:
			target.get_parent().get_parent().get_parent().apply_magnum_opus_stack(magnum_opus_stack_on_hit)
			target.get_parent().get_parent().get_parent().take_damage(damage,multi_hit_proc_chance,direction_to_target * 0.1)
			queue_free()
	else:
		queue_free()

