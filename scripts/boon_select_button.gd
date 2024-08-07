extends Button
var original_size := scale
var grow_size := Vector2(1.05,1.05)

signal boon_selected(boon_type,boon_id)

var boon_type
var boon_id

func initialize_boon_button(new_boon_type,new_boon_id):
	boon_type = new_boon_type
	boon_id = new_boon_id
	

func _on_mouse_entered():
	pass
	#grow_bttn(grow_size,0.1)


func _on_mouse_exited():
	pass
	#grow_bttn(original_size,0.1)

func grow_bttn(end_size:Vector2, duration:float):
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self,'scale',end_size,duration)


func _on_pressed():
	emit_signal("boon_selected",boon_type,boon_id)
