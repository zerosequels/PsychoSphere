extends CanvasLayer

@onready var text_rect = $TextureRect
@onready var anim_player = $AnimationPlayer

func _ready():
	text_rect.visible = false
	anim_player.animation_finished.connect(_on_fade_in_finished)
	
func fade_out():
	text_rect.visible = true
	anim_player.play("fade_out")

func fade_in():
	text_rect.visible = true
	anim_player.play("fade_in")

func _on_fade_in_finished(name:StringName):
	if name == "fade_in":
		get_tree().change_scene_to_file("res://scenes/reset_scene.tscn")
	elif name == "fade_out":
		text_rect.visible = false
