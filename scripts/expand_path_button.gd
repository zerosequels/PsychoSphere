extends Node3D

@export var trigger_id: String = "bababooey"
@export var trigger_uuid = ResourceUID.create_id()
@export var depth_counter:int = 0
@onready var button = $expand_path_mesh
@onready var portal = $portal
@onready var enemy_prefab = preload("res://scenes/enemy.tscn")

var is_triggerable:bool = true
var last_spawn_time = 0

@export var enemy_spawn_data_array = []
@export var parent_path:Path3D
var main

signal enemy_spawned(enemy)

signal path_trigger_activated(trigger_id:String, trigger_uuid:int,depth:int)

func _ready():
	main = get_parent()


func get_next_enemy_data():
	if !enemy_spawn_data_array.is_empty():
		return enemy_spawn_data_array.pop_front()

func load_enemy_spawn_data():
	enemy_spawn_data_array = WaveData.get_enemy_spawn_data_array_by_level(depth_counter)

func has_enemies_to_spawn():
	return !enemy_spawn_data_array.is_empty()

func toggle_visibility():
	is_triggerable = !is_triggerable
	if is_triggerable:
		button.visible = true
		portal.visible = false
	else:
		button.visible = false
		portal.visible = true

func _process(delta):
	if !is_triggerable and has_enemies_to_spawn():
		process_spawn_opportunity()

func process_spawn_opportunity():
		#var enemy_spawn_data = enemy_spawn_data_array.pop_front()
	var spawn_time = 1000
	var enemy_spawn_data
	if !enemy_spawn_data_array.is_empty():
		#print("enemy spawn data array has enemies to spawn")
		enemy_spawn_data = enemy_spawn_data_array[0]
		#print(enemy_spawn_data.time_to_spawn_ms)
		spawn_time = enemy_spawn_data.time_to_spawn_ms
	
	if Time.get_ticks_msec() > (last_spawn_time + spawn_time):
		if !enemy_spawn_data_array.is_empty():
			enemy_spawn_data = enemy_spawn_data_array.pop_front()
			spawn_enemy_as_child_of_path_follow(enemy_spawn_data)
			#print("enemy spawned")
			last_spawn_time = Time.get_ticks_msec()

func spawn_enemy_as_child_of_path_follow(enemy_data:EnemySpawnData):
	var enemy = enemy_prefab.instantiate()
	enemy.update_values_by_enemy_spawn_data(enemy_data)
	parent_path.add_child(enemy)
	emit_signal("enemy_spawned",enemy)

func set_trigger_id(new_trigger_id:String):
	trigger_id = new_trigger_id

func activate_trigger():
	if is_triggerable:
		#print(depth_counter)
		emit_signal("path_trigger_activated",trigger_id,trigger_uuid,depth_counter)
		#delete self
		self.queue_free()
	
