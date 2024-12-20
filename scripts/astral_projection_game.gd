extends Node3D

@onready var path_controller = $path_controller


func _ready():
	path_controller._initialize(1)
	path_controller.generate_random_chunk()









func _process(delta):
	pass
