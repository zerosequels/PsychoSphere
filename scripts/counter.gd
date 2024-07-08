extends Control
@onready var counter:Label = $TextureRect/Label

func set_counter_value(new_text:String):
	counter.text = new_text

func set_visibility(vis:bool):
	visible = vis
