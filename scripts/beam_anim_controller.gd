extends Node3D

@onready var beam_anim_player = $beam_anim_player


func _ready():
	print("wtf")
	#beam_anim_player.autoplay = ""

func fire_beam_anim():
	print("firing")
	beam_anim_player.play("beam_effect")

