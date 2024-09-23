extends Control

signal astral_projection_begin

func _on_play_button_pressed():
	emit_signal("astral_projection_begin")
	


func _on_upgrade_button_pressed():
	pass # Replace with function body.


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
