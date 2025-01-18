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


func update_button_by_key(key:String):
	print("updating button")
	print(key)
	
	power_up_name = key
	$MarginContainer/HBoxContainer/VBoxContainer/title_label.text = power_up_name
	var memo_format = "[center]%s[/center]" % key.to_upper().replace(' ', '_')
	$MarginContainer/HBoxContainer/VBoxContainer/description_label.text = memo_format

func _on_pressed():
	emit_signal("show_memo", power_up_name)
