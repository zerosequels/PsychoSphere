extends Node3D

var is_right = true
var needle_speed = 7

func _process(delta):
	rotate_y(needle_speed * delta)
	if rotation_degrees.y >= 15 and is_right:
		toggle_direction()
	elif rotation_degrees.y <= -15 and !is_right:
		toggle_direction()
	
func toggle_direction():
	is_right = !is_right
	needle_speed = needle_speed * -1
	
