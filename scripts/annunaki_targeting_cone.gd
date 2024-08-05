extends Node3D

var camera

func _ready():
	camera = get_viewport().get_camera_3d()


func _process(delta):
	look_at(camera.global_transform.origin, Vector3.UP)
