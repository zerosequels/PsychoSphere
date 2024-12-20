extends Control

const boon_button_prefab = preload("res://scenes/boon_select_button.tscn")

#@onready var grid_container = $MarginContainer/VBoxContainer/GridContainer
@onready var h_box = $MarginContainer/VBoxContainer/HBoxContainer

var option_array = []
var path_trigger_id
var path_trigger_uuid
var path_depth

signal close_menu(trigger_id,trigger_uuid,depth)

enum boon_types {
	unlock,
	boost,
	tower,
	out_of_boons
}

func _ready():
	pass
	
func load_new_boons_from_data(trigger_id,trigger_uuid,depth):
	path_trigger_id = trigger_id
	path_trigger_uuid = trigger_uuid
	path_depth = depth
	get_boon_to_display()
	get_boon_to_display()
	get_boon_to_display()

func get_boon_to_display():
	var boon_type = TowerAndBoonData.get_boon_type()
	match boon_type:
		boon_types.out_of_boons:
			create_empty_boon_option_button()
		boon_types.unlock:
			pass
		boon_types.boost:
			var boost_id = TowerAndBoonData.get_random_boost()
			create_boost_option_button(TowerAndBoonData.get_boost_name_by_boost_type(boost_id),TowerAndBoonData.get_boost_description_by_boost_type(boost_id),boon_type,boost_id)
		boon_types.tower:
			var tower_boon_id = TowerAndBoonData.get_random_tower_to_unlock()
			create_boon_option_button(TowerAndBoonData.get_tower_unlock_name_by_tower_type(tower_boon_id),TowerAndBoonData.get_tower_unlock_description_by_tower_type(tower_boon_id),boon_type,tower_boon_id)
	

func _on_boon_selected(new_boon_type,new_boon_id):
	match new_boon_type:
		boon_types.out_of_boons:
			clear_boon_options()
			emit_signal("close_menu",path_trigger_id,path_trigger_uuid,path_depth)
		boon_types.unlock:
			pass
		boon_types.boost:
			TowerAndBoonData.increase_awareness_by_boost_type(new_boon_id)
			clear_boon_options()
			emit_signal("close_menu",path_trigger_id,path_trigger_uuid,path_depth)
		boon_types.tower:
			TowerAndBoonData.unlock_tower_by_tower_type(new_boon_id)
			clear_boon_options()
			emit_signal("close_menu",path_trigger_id,path_trigger_uuid,path_depth)

func clear_boon_options():
	for btn in option_array:
		btn.queue_free()
	option_array.clear()

func create_empty_boon_option_button():
	var btn = boon_button_prefab.instantiate()
	btn.set_boon_name("404 BOON NOT FOUND")
	btn.set_boon_description("Still under construction, check back in a future update")
	btn.initialize_boon_button(boon_types.out_of_boons,-1)
	btn.boon_selected.connect(_on_boon_selected)
	h_box.add_child(btn)
	option_array.append(btn)

func create_boon_option_button(boon_name:String, boon_description:String,type,boon_id):
	var btn = boon_button_prefab.instantiate()
	btn.set_boon_name(boon_name)
	btn.set_boon_texture_by_boon_type(boon_id)
	btn.set_boon_description(boon_description)
	btn.initialize_boon_button(type,boon_id)
	btn.boon_selected.connect(_on_boon_selected)
	h_box.add_child(btn)
	option_array.append(btn)

func create_boost_option_button(boon_name:String, boon_description:String,type,boon_id):
	var btn = boon_button_prefab.instantiate()
	btn.set_boon_name(boon_name)
	btn.set_boon_texture_under_construction()
	btn.set_boon_description(boon_description)
	btn.initialize_boon_button(type,boon_id)
	btn.boon_selected.connect(_on_boon_selected)
	h_box.add_child(btn)
	option_array.append(btn)
