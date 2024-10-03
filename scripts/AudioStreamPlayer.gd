extends AudioStreamPlayer

var should_loop_lab_theme: bool = true
var should_loop_main_theme: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func play_lab_theme():
	should_loop_lab_theme = true
	play()
	
func stop_lab_theme():
	
	should_loop_lab_theme = false
	stop()
	
func _on_finished():
	if should_loop_lab_theme:
		play_lab_theme()

func play_main_theme():
	should_loop_main_theme = true
	$main_theme_player.play()
	
func stop_main_theme():
	should_loop_main_theme = false
	$main_theme_player.stop()


func _on_main_theme_player_finished():
	if should_loop_main_theme:
		play_main_theme()
