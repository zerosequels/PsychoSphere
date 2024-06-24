extends StaticBody3D

signal mouse_detector_hovered()

func mouse_detector_hit():
	emit_signal("mouse_detector_hovered")
