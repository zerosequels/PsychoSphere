extends Node3D

@export var rot_speed:float = 1


func _process(delta):
	rotate_z(rot_speed * delta)
