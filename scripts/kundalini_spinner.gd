extends Node3D


var rot_speed = -6;


func _process(delta):
	rotate_y(rot_speed * delta)
