extends Control

@onready var health_label = %hemisync_percent
@onready var difficulty_label = %difficulty_level_value
@onready var awareness_level = %awareness_value

func _ready():
	set_health(100)
	set_difficulty(0)
	set_awareness(100)
	
	
func set_health(new_value:int):
	var health_format = "%s"
	var new_string:String = health_format % new_value
	new_string += "%"
	
	health_label.text = new_string
	
func set_difficulty(new_value:int):
	var difficulty_format = "%s"
	var new_string:String = difficulty_format % new_value
	new_string += "%"
	
	difficulty_label.text = new_string
	
func set_awareness(new_value:int):
	awareness_level.text = "$$$" + str(new_value)
