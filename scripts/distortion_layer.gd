extends Sprite2D

var fadeout:bool = false
var shader_value = material.get_shader_parameter("distortion_strength")
var speed = 0.001

var max_val = 0.2
var min_val = 0.0

func _physics_process(delta: float) -> void:
	if(fadeout):
		shader_value += speed
	else:
		shader_value -= speed

	shader_value = clamp(shader_value,0.0,0.2)
	
	material.set_shader_parameter("distortion_strength",shader_value)

func trigger_distortion():
	fadeout = true
