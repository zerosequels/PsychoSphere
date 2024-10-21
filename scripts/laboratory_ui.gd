extends Control

signal astral_projection_begin
@onready var distortion_layer:Sprite2D = $distortion_layer

func _on_play_button_pressed():
	emit_signal("astral_projection_begin")
	increase_ui_distortion()


func _on_upgrade_button_pressed():
	pass # Replace with function body.


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
	
func increase_ui_distortion():
	distortion_layer.trigger_distortion()



func _on_credits_button_button_up():
	get_tree().change_scene_to_file("res://scenes/credits_screen.tscn")
