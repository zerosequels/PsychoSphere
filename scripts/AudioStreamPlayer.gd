extends AudioStreamPlayer

var should_loop_lab_theme: bool = true
var should_loop_main_theme: bool = true

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
		
func tower_placed_sfx():
	$tower_placement_player.play()
	
func tower_removed_sfx():
	$tower_removal_player.play()
	
func speed_change_sfx():
	$speed_change_player.play()
	
func play_enemy_hit():
	$enemy_hit_audio_stream_player.play()

func play_enemy_crit_hit():
	$enemy_crit_hit_audio_stream_player.play()

func play_quit():
	$quit_audio_stream_player.play()
	
func play_game_over():
	$game_over_stream_player.play()

func play_path_trigger_selected_audio_stream_player():
	$path_trigger_selected_audio_stream_player.play()

func boon_selected_audio_stream_player():
	$boon_selected_audio_stream_player.play()

func on_enemy_reached_center_stream_player():
	$on_enemy_reached_center_stream_player.play()

func on_enemy_dead_audio_stream_player():
	$on_enemy_dead_audio_stream_player.play()

func on_tower_placed_audio_stream_player():
	$on_tower_placed_audio_stream_player.play()

func on_card_select_audio_stream_player():
	$on_card_select_audio_stream_player.play()

func on_card_deselected_audio_stream_player():
	$on_card_deselected_audio_stream_player.play()
