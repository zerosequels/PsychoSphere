extends Node3D

@onready var laser_mesh = $laser_mesh
var is_firing:bool = false
var laser_target:Node3D

func set_is_firing(toggle:bool):
	is_firing = toggle
	
func set_laser_target(target:Node3D):
	laser_target = target

#TODO laser doesn't line up to enemy, may be result of the offset of the enemy or this logic
func _process(delta):
	if is_firing:
		laser_mesh.mesh.height = global_position.distance_to(laser_target.global_position)
		
		laser_mesh.position.y = global_position.distance_to(laser_target.global_position)/2
	else:
		laser_mesh.position.y = 0
		laser_mesh.mesh.height = 0.01
	#cast_point = to_local(get_collision_point())
	#laser_mesh.mesh.height = cast_point.y
	#laser_mesh.position.y =  cast_point.y/2
		
