extends Node3D

@onready var egg_scaler = $egg_scaler


func set_egg_scale(egg_scale):
	egg_scale = egg_scale/10
	egg_scaler.scale = Vector3(egg_scale,egg_scale,egg_scale)
