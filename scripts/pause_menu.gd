extends Control

@onready var resume_bttn = $PanelContainer/MarginContainer/VBoxContainer/resume_bttn
@onready var restart_bttn = $PanelContainer/MarginContainer/VBoxContainer/restart_bttn
@onready var quit_bttn = $PanelContainer/MarginContainer/VBoxContainer/quit_bttn
@onready var game_over_label = $PanelContainer/MarginContainer/VBoxContainer/game_over_label

func _ready():
	resume_bttn.disabled = true
	restart_bttn.disabled = true
	quit_bttn.disabled = true
	$AnimationPlayer.play("RESET")

func _process(delta):
	detect_escape_key_pressed()
	
func fade_out_menu():
	$fade_screen.fade_out()
	
func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")
	resume_bttn.disabled = true
	restart_bttn.disabled = true
	quit_bttn.disabled = true
	game_over_label.visible = false
	
func pause():
	resume_bttn.disabled = false
	restart_bttn.disabled = false
	quit_bttn.disabled = false
	get_tree().paused = true
	$AnimationPlayer.play("blur")
	game_over_label.visible = false

func game_over_pause():
	resume_bttn.disabled = true
	resume_bttn.visible = false
	restart_bttn.disabled = false
	quit_bttn.disabled = false
	game_over_label.visible = true
	game_over_label.text = "GAME OVER"
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func victory_pause():
	resume_bttn.disabled = true
	resume_bttn.visible = false
	restart_bttn.disabled = false
	quit_bttn.disabled = false
	game_over_label.visible = true
	game_over_label.text = "YOU WIN"
	get_tree().paused = true
	$AnimationPlayer.play("blur")
		
func detect_escape_key_pressed():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("esc") and get_tree().paused == true:
		resume()

func activate_game_over_menu():
	if get_tree().paused == true:
		resume()
	game_over_pause()

func activate_victory_menu():
	if get_tree().paused == true:
		resume()
	victory_pause()

func restart():
	WaveData.reset_game_data()
	TowerAndBoonData.reset_tower_and_boon_data()
	$fade_screen.fade_in()
	
	
func quit():
	get_tree().quit()
	
func _on_resume_bttn_pressed():
	resume()


func _on_restart_bttn_pressed():
	resume()
	restart()


func _on_quit_bttn_pressed():
	$quit_audio_stream_player.play()
	await get_tree().create_timer(2.0).timeout
	quit()
