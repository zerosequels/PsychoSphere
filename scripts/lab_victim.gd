extends Node3D
@onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.play("wake_up_and_fry")
	
	
func _on_animation_player_animation_finished(anim_name):
	anim_player.queue("wake_up_and_fry")
