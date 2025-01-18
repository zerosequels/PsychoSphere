extends Node3D

@export var trigger_id = -1
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
var can_be_selected:bool = true
signal enemy_spawned(enemy)

signal path_trigger_activated(trigger_id:int, trigger_uuid:int,depth:int)

func _ready():
	main = get_parent()

func toggle_can_select(toggle:bool):
	can_be_selected = toggle

func get_next_enemy_data():
	if !enemy_spawn_data_array.is_empty():
		return enemy_spawn_data_array.pop_front()

func load_enemy_spawn_data():
	enemy_spawn_data_array = WaveData.get_enemy_spawn_data_array_by_trigger_id(trigger_id)
	#enemy_spawn_data_array = WaveData.get_enemy_spawn_data_array_by_level(depth_counter)

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
	enemy.update_model_scale()
	enemy.update_model_color()
	emit_signal("enemy_spawned",enemy)

func set_trigger_id(new_trigger_id):
	trigger_id = new_trigger_id

func activate_trigger():
	if !can_be_selected:
		return
	if is_triggerable:
		#await get_tree().create_timer(0.5)
		emit_signal("path_trigger_activated",trigger_id,trigger_uuid,depth_counter)
		add_enemies_to_queue_by_trigger_id()
		#delete self
		self.queue_free()
func add_enemies_to_queue_by_trigger_id():
	WaveData.add_enemies_to_queue_by_trigger_id(trigger_id)
	
