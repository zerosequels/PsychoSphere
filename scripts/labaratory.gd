extends Node3D

var timer
var anim_player
var game_is_starting:bool = false

func _process(delta):
	if game_is_starting:
		if Input.is_action_just_pressed("click"):
			get_tree().change_scene_to_file("res://scenes/tutorial_instructions.tscn")

func _ready():
	get_tree().paused = false
	$CanvasLayer/laboratory_ui.astral_projection_begin.connect(_on_astral_projection_begin)
	play_intro_sound()
	
	timer = Timer.new()
	timer.wait_time = 3.5
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	add_child(timer)
	
	anim_player = $camera_boom/AnimationPlayer
	
	GlobalAudio.play_lab_theme()

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/tutorial_instructions.tscn")

func _on_astral_projection_begin():
	if game_is_starting:
		get_tree().change_scene_to_file("res://scenes/tutorial_instructions.tscn")
	play_astral_projection_sound()
	timer.start()
	anim_player.play("camera_zoom_in")
	game_is_starting = true

func play_intro_sound():
	$AudioStreamPlayer.play()
	
func play_astral_projection_sound():
	$AudioStreamPlayer2.play()
