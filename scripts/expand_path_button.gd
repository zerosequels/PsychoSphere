extends Node3D

@export var trigger_id: String = "bababooey"
@export var trigger_uuid = ResourceUID.create_id()
@onready var button = $expand_path_mesh
@onready var portal = $portal

var is_triggerable:bool = true


signal path_trigger_activated(trigger_id:String, trigger_uuid:int)

func toggle_visibility():
	is_triggerable = !is_triggerable
	if is_triggerable:
		button.visible = true
		portal.visible = false
	else:
		button.visible = false
		portal.visible = true
		

func set_trigger_id(new_trigger_id:String):
	trigger_id = new_trigger_id

func activate_trigger():
	if is_triggerable:
		emit_signal("path_trigger_activated",trigger_id,trigger_uuid)
		#delete self
		self.queue_free()
	
