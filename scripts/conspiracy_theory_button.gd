extends Button

signal show_memo(key: String)

@export var power_up_name: String = ""
@export var power_up_description: String =  ""
@export var power_up_lore:String = ""
@export var description_font_size: int = 15
@export var power_up_id:int
@export var level : int = 0

@onready var description_label:Label = $MarginContainer/HBoxContainer/VBoxContainer/description_label


@onready var custom_font = preload("res://assets/ui/GelatinTTFCAPS.ttf")


	
# Called when the node enters the scene tree for the first time.
func _ready():
	description_label.add_theme_font_override("font", custom_font)
	description_label.add_theme_font_size_override("font_size", description_font_size)
	$MarginContainer/HBoxContainer/VBoxContainer/title_label.text = power_up_name
	$MarginContainer/HBoxContainer/VBoxContainer/description_label.text = power_up_description
	var level_label_format = "%s/3"
	var level_label_text = level_label_format % level
	$MarginContainer/level_label.text = level_label_text

func set_description(description):
	$MarginContainer/HBoxContainer/VBoxContainer/description_label.text = description

func override_image(texture_path):
	$MarginContainer/HBoxContainer/TextureRect.texture = load(texture_path)

func override_name(override_name):
	$MarginContainer/HBoxContainer/VBoxContainer/title_label.text = override_name

func override_availability(is_available):
	if is_available == 0:
		disabled = true
	else:
		disabled = false
	

func update_button_by_key(key:String):
	print("updating button")
	print(key)
	
	power_up_name = key
	override_name(TowerAndBoonData.memo_content[key].name_override)
	set_description(TowerAndBoonData.memo_content[key].text)
	override_image(TowerAndBoonData.memo_content[key].image)
	override_level(TowerAndBoonData.memo_content[key].level)
	#button_instance.override_availability(TowerAndBoonData.memo_content[key].is_available)
	

func override_level(new_level):
	var level_format = "%s/3"
	$MarginContainer/level_label.text = level_format % new_level


func _on_pressed():
	emit_signal("show_memo", power_up_name)
