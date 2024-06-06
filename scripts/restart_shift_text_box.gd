extends Control
@onready var upper_text:Label = $PanelContainer/TextureRect/VBoxContainer/upper_text
@onready var lower_text:Label = $PanelContainer/TextureRect/VBoxContainer/lower_text
var last_toggle_time = 0
var toggle_ms = 200
var is_flashing:bool = true

func _process(delta):
	if Time.get_ticks_msec() > (last_toggle_time + toggle_ms):
		if is_flashing:
			upper_text.add_theme_color_override("font_color", Color.BLACK)
			lower_text.add_theme_color_override("font_color", Color.BLACK)
			is_flashing = false
			last_toggle_time = Time.get_ticks_msec()
		else:
			upper_text.add_theme_color_override("font_color", Color.AQUA)
			lower_text.add_theme_color_override("font_color", Color.AQUA)
			is_flashing = true
			last_toggle_time = Time.get_ticks_msec()
		
