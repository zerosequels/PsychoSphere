extends Node3D

@onready var cone_1 = $Cone
@onready var cone_2 = $Cone_001
var rot_speed = 3;


func _process(delta):
	cone_1.rotate_y(rot_speed * delta)
	cone_2.rotate_y(rot_speed * delta)
