extends Node3D
@onready var vibe_animator:AnimationPlayer = $AnimationPlayer

func _ready():
	vibe_animator.get_animation("ArmatureAction").loop_mode = 2
	vibe_animator.play("ArmatureAction")
