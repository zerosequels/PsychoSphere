extends Node3D

var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/laboratory_ui.astral_projection_begin.connect(_on_astral_projection_begin)
	play_intro_sound()
	
	timer = Timer.new()
	timer.wait_time = 4.5
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	add_child(timer)
	

func _on_timer_timeout():
	print("begin")
	get_tree().change_scene_to_file("res://scenes/demo_screen.tscn")

func _on_astral_projection_begin():
	play_astral_projection_sound()
	timer.start()

func play_intro_sound():
	$AudioStreamPlayer.play()
	
func play_astral_projection_sound():
	$AudioStreamPlayer2.play()
