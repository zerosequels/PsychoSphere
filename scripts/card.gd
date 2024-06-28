extends Control

@onready var tower_name_label:Label = $tower_type_label
@onready  var tower_price_label:Label = $tower_price_label
@onready var tower_sprite = $tower_sprite
@onready var card_sprite = $card_sprite
@onready var mouse_detector = $ui_mouse_detector

@export var angle_x_max: float = 4.0
@export var angle_y_max: float = 4.0

@export_category("Oscillator")
@export var spring: float = 150.0
@export var damp: float = 10.0
@export var velocity_multiplier: float = 2.0

var displacement: float = 0.0 
var oscillator_velocity: float = 0.0

var tween_rot: Tween
var tween_hover: Tween


var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = false
var last_pos: Vector2
var velocity: Vector2

var tower_name:String = "option name"
var tower_price: int = 10
var tower_type = 0
var is_selected:bool = false

signal card_selected(tower_type_enum:int,tower_price:int)
signal price_updated(tower_type_enum:int,tower_price:int)
signal is_card_hovered(is_hovered:bool)

func _ready():
	set_tower_name(tower_name)
	set_price(tower_price)
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)

func set_price(new_price:int):
	tower_price = new_price
	tower_price_label.text = str(tower_price)
	
func set_tower_name(new_name:String):
	tower_name = new_name
	tower_name_label.text = tower_name

func set_tower_type(type:int):
	tower_type = type

func increment_tower_price(type:int):
	set_price(TowerAndBoonData.get_next_tower_price_and_increment_count(type))
	emit_signal("price_updated",tower_type,tower_price)

func get_tower_type():
	return tower_type

func handle_mouse_click(event: InputEvent):
	#TODO add more tower types, and an enum representing them
	if not event is InputEventMouseButton: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.is_pressed():
		set_is_selected(!is_selected)
		emit_signal("card_selected",tower_type,tower_price)

func set_is_selected(is_now_selected:bool):
	is_selected = is_now_selected
	update_selected_offset()

func update_selected_offset():
	#TODO figure out how to create some visual indicator of which card is selected
	if !is_selected:
		if tween_hover and tween_hover.is_running():
			tween_hover.kill()
		tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
	else:
		if tween_hover and tween_hover.is_running():
			tween_hover.kill()
		tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		tween_hover.tween_property(self, "scale", Vector2(1.4, 1.4), 0.5)

func _on_ui_mouse_detector_gui_input(event):
	handle_mouse_click(event)
	if not event is InputEventMouseMotion: return
	var mouse_pos: Vector2 = get_local_mouse_position()
	var diff: Vector2 = (mouse_detector.position + mouse_detector.size) - mouse_pos
	var lerp_val_x: float = remap(mouse_pos.x, 0.0, mouse_detector.size.x/10, 0, 1)

	var lerp_val_y: float = remap(mouse_pos.y, 0.0, mouse_detector.size.y/5, 0, 1)
	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	card_sprite.material.set_shader_parameter("x_rot", rot_y)
	card_sprite.material.set_shader_parameter("y_rot", rot_x)
	tower_sprite.material.set_shader_parameter("x_rot", rot_y)
	tower_sprite.material.set_shader_parameter("y_rot", rot_x)

	

func _on_ui_mouse_detector_mouse_entered():
	if is_selected:
		emit_signal("is_card_hovered",true)
		return
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2(1.2, 1.2), 0.5)
	emit_signal("is_card_hovered",true)


func _on_ui_mouse_detector_mouse_exited():
	# Reset rotation
	
	if tween_rot and tween_rot.is_running():
		tween_rot.kill()
	tween_rot = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK).set_parallel(true)
	tween_rot.tween_property(card_sprite.material, "shader_parameter/x_rot", 0.0, 0.1)
	tween_rot.tween_property(card_sprite.material, "shader_parameter/y_rot", 0.0, 0.1)
	tween_rot.tween_property(tower_sprite.material, "shader_parameter/x_rot", 0.0, 0.1)
	tween_rot.tween_property(tower_sprite.material, "shader_parameter/y_rot", 0.0, 0.1)
	
	if is_selected:
		emit_signal("is_card_hovered",false)
		return
	# Reset scale
	if tween_hover and tween_hover.is_running():
		tween_hover.kill()
	tween_hover = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_hover.tween_property(self, "scale", Vector2.ONE, 0.55)
	emit_signal("is_card_hovered",false)





