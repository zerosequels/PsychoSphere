extends Node3D

var tween

var is_wiggling = false
var original_position:Vector3 = Vector3(0,0,0)

func set_original_position(pos:Vector3):
	position = pos
	original_position = pos
	
func damage_wiggle(wiggle_direction:Vector3,is_crit:bool):

	if is_wiggling:
		return
	else:
		tween = get_tree().create_tween()
		is_wiggling = true
		tween.set_loops(1)
		if is_crit:
			tween.tween_property(self, "position",wiggle_direction, 0.3).set_trans(Tween.TRANS_SPRING)
			tween.tween_property(self, "position",original_position, 0.3).set_trans(Tween.TRANS_SPRING)
		else:
			tween.tween_property(self, "position",wiggle_direction, 0.1).set_trans(Tween.TRANS_SPRING)
			tween.tween_property(self, "position",original_position, 0.1).set_trans(Tween.TRANS_SPRING)
		tween.tween_callback(_on_stop_wiggling)
		tween.play()
	
func _on_stop_wiggling():
	is_wiggling = false


