extends Control

var index = 0

func increase_index():
	index += 1
	if index == 8:
		get_tree().change_scene_to_file("res://scenes/main.tscn")
	index = clamp(index,0,7)
	update_text()
	

func decrease_index():
	if index == 0:
		get_tree().change_scene_to_file("res://scenes/laboratory.tscn")
	index -= 1
	index = clamp(index,0,7)
	update_text()
	
func hide_text():
	$MarginContainer2/zero.visible = false
	$MarginContainer2/zero_and_one_half.visible = false
	$MarginContainer2/one.visible = false
	$MarginContainer2/two.visible = false
	$MarginContainer2/three.visible = false
	$MarginContainer2/four.visible = false
	$MarginContainer2/five.visible = false
	$MarginContainer2/six.visible = false
	$MarginContainer2/return_of_the_zero.visible = false
	$Victim.visible = false
	$trigger.visible = false
	$spiral.visible = false

func update_text():
	hide_text()
	match index:
		0:
			$MarginContainer2/zero.visible = true
			$Victim.visible = true
		1:
			$MarginContainer2/zero_and_one_half.visible = true
			$Victim.visible = true
		2:
			$MarginContainer2/return_of_the_zero.visible = true
			$Victim.visible = true
		3:
			$MarginContainer2/one.visible = true
			$Victim.visible = true
		4:
			$MarginContainer2/two.visible = true
			$trigger.visible = true
		5:
			$MarginContainer2/three.visible = true
			$spiral.visible = true
		6:
			$MarginContainer2/four.visible = true
			$Victim.visible = true
		7:
			$MarginContainer2/five.visible = true
			$Victim.visible = true
		8:
			$MarginContainer2/six.visible = true
			$Victim.visible = true


func _on_back_button_pressed():
	decrease_index()


func _on_next_button_pressed():
	increase_index()
