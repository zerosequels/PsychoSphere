extends Node3D

var tween

var is_wiggling = false
	
func damage_wiggle():
	
	
	if is_wiggling:
		return
	else:
		tween = get_tree().create_tween()
		is_wiggling = true
		tween.set_loops(1)
		tween.tween_property(self, "position",Vector3(randf_range(-0.3,0.3),randf_range(-0.3,0.3),randf_range(-0.3,0.3)), 0.1).set_trans(Tween.TRANS_SPRING)
		tween.tween_property(self, "position",Vector3(0,0,0), 0.1).set_trans(Tween.TRANS_SPRING)
		tween.tween_callback(_on_stop_wiggling)
		tween.play()
	
func _on_stop_wiggling():
	is_wiggling = false


