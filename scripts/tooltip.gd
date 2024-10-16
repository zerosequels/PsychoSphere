class_name Tooltip extends Node

@export var visual_res: PackedScene
@export var owner_path: NodePath
@export var delay:float = 2.0
@onready var owner_node = get_node(owner_path)
@export var follow_mouse:bool = true
@export var offset_x:float = 0
@export var offset_y:float = 0
@export var tip_text:String

var visuals:Control
var timer:Timer

@onready var offset:Vector2 = Vector2(offset_x,offset_y)


func _ready():
	visuals = visual_res.instantiate()
	add_child(visuals)
	visuals.set_tool_tip_text(tip_text)
	owner_node.mouse_entered.connect(_on_mouse_entered)
	owner_node.mouse_exited.connect(_on_mouse_exited)
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	visuals.hide()
	
func _process(delta):
	if visuals.visible:
		var base_pos = get_screen_position()
		var final_x = base_pos.x
		var final_y = base_pos.y - 100
		visuals.global_position = Vector2(final_x,final_y)
	

func _on_timer_timeout():
	timer.stop()
	var base_pos = get_screen_position()
	var final_x = base_pos.x
	var final_y = base_pos.y - 100
	visuals.global_position = Vector2(final_x,final_y)
	visuals.show()

func _on_mouse_entered():
	timer.start(delay)
	
func _on_mouse_exited():
	timer.stop()
	visuals.hide()
	
func get_screen_position():
	if follow_mouse:
		return get_viewport().get_mouse_position()
		

	var position = Vector2()
	
	if owner_node is Node2D:
		position = owner_node.get_global_transform_with_canvas().origin
	if owner_node is Control:
		pass
	
	return position
