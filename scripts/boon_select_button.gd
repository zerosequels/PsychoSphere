extends Button
var original_size := scale
var grow_size := Vector2(1.05,1.05)

signal boon_selected(boon_type,boon_id)

var boon_type
var boon_id
var activated = false

func initialize_boon_button(new_boon_type,new_boon_id):
	boon_type = new_boon_type
	boon_id = new_boon_id
	

func set_boon_name(new_boon_name):
	$MarginContainer/VBoxContainer/boon_name.text = new_boon_name

func set_boon_description(new_boon_description):
	$MarginContainer/VBoxContainer/boon_description.text = new_boon_description

func set_boon_texture_by_boon_type(boon_type):
	$MarginContainer/VBoxContainer/boon_texture.texture = TowerAndBoonData.get_tower_unlock_texture_by_tower_type(boon_type)

func _on_mouse_entered():
	pass
	#grow_bttn(grow_size,0.1)


func _on_mouse_exited():
	pass
	#grow_bttn(original_size,0.1)

func grow_bttn(end_size:Vector2, duration:float):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,'scale',end_size,duration)


func _on_button_up():
	if activated:
		emit_signal("boon_selected",boon_type,boon_id)



func _on_timer_timeout():
	activated = true
