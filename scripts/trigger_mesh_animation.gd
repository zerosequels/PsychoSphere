extends MeshInstance3D

@export var rot_speed:float = 1



func _process(delta):
	rotate_y(rot_speed * delta)
