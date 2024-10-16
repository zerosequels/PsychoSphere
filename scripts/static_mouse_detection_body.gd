extends StaticBody3D

signal mouse_detector_hovered()
signal tower_clicked()

func mouse_detector_hit():
	emit_signal("mouse_detector_hovered")

func mouse_click():
	#print("clicked")
	emit_signal("tower_clicked")
