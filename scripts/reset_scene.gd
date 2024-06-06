extends Node3D

func _ready():

	var timer := Timer.new()
	timer.wait_time = 2.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	add_child(timer)
	timer.start()
	$AnimationPlayer.play("zoomerang")
	
	$AudioStreamPlayer.play()


func _on_timer_timeout():
	$AudioStreamPlayer2.play()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

