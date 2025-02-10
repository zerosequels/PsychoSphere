extends Node3D

var zoom_input:float

var zoom_min:float = -69
var zoom_max:float = 8
var zoom_value:float = 8
var zoom_speed:float = 0.2
var should_scroll =  true
@onready var ui = $ui
# Called when the node enters the scene tree for the first time.
func _ready():
	ui.memo_toggled.connect(_toggle_memo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("esc")):
		get_tree().change_scene_to_file("res://scenes/laboratory.tscn")
	if (Input.is_action_pressed("camera_zoom_out") or Input.is_action_just_released("camera_zoom_out")) and should_scroll:
		zoom_value -= zoom_speed
		zoom_value = maxf(zoom_value,zoom_min)
	if (Input.is_action_pressed("camera_zoom_in") or Input.is_action_just_released("camera_zoom_in")) and should_scroll:
		zoom_value += zoom_speed
		zoom_value = minf(zoom_value,zoom_max)
	$Camera3D.position.y = zoom_value
	ui.set_ui_offset(zoom_value * 170)

func _toggle_memo(is_memo_visible):
	should_scroll = !is_memo_visible 
