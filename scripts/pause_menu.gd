extends Control

@onready var resume_bttn = $PanelContainer/MarginContainer/VBoxContainer/resume_bttn
@onready var restart_bttn = $PanelContainer/MarginContainer/VBoxContainer/restart_bttn
@onready var quit_bttn = $PanelContainer/MarginContainer/VBoxContainer/quit_bttn

func _ready():
	resume_bttn.disabled = true
	restart_bttn.disabled = true
	quit_bttn.disabled = true
	$AnimationPlayer.play("RESET")

func _process(delta):
	detect_escape_key_pressed()

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	resume_bttn.disabled = true
	restart_bttn.disabled = true
	quit_bttn.disabled = true
	
func pause():
	resume_bttn.disabled = false
	restart_bttn.disabled = false
	quit_bttn.disabled = false
	get_tree().paused = true
	$AnimationPlayer.play("blur")
		
func detect_escape_key_pressed():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()

func restart():
	get_tree().change_scene_to_file("res://scenes/reset_scene.tscn")
	
	
func quit():
	get_tree().quit()
	
func _on_resume_bttn_pressed():
	resume()


func _on_restart_bttn_pressed():
	resume()
	restart()


func _on_quit_bttn_pressed():
	quit()
