extends Node3D

func _ready():
	print("reset scene activted")

	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	add_child(timer)
	timer.start()
	$AnimationPlayer.play("zoom_bounce")
	
	$AudioStreamPlayer.play()


func _on_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

