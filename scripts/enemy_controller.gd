extends PathFollow3D

@export var speed = 1

@export var health:float = 100
@export var damage_on_hit:float = 1
@export var exp_on_kill = 1

@export var enemy_uuid = ResourceUID.create_id()
@onready var enemy_model_controller = $enemy/model_scaler
@onready var model = $enemy/model_scaler/enemy_model
@onready var ui_origin = $enemy/damage_number_origin
@onready var health_bar = $enemy/damage_number_origin/health_bar
@onready var ticker = $enemy/damage_number_origin/ticker
@onready var projectile = preload("res://scenes/projectile.tscn")

var base_crit_rate = 0.05
var crit_increase_per_stack = 0.05

var is_criting = false

var enemy_scale_value: float = 1
var is_slow:bool = false

var glow_decay_timer: Timer
var magnum_opus_decay_timer: Timer
var cubic_decay_timer: Timer
var slow_decay_timer: Timer

signal reached_the_center(damage:int, enemy_uuid:int)
signal enemy_killed(exp:int, enemy_uuid:int)

var slowness = 1
var multi_hit_targets = []

var primary_color
var highlight_color

var height_offset

func _ready():
	GameMode.update_game_speed.connect(_on_refresh_decay_timers)
	var starting_speed = GameMode.get_global_game_speed()
	glow_decay_timer = Timer.new()
	glow_decay_timer.one_shot = false
	glow_decay_timer.autostart = true
	glow_decay_timer.timeout.connect(process_glowing_decay_opportunity)
	refresh_decay_timer(starting_speed)
	add_child(glow_decay_timer)
	
	magnum_opus_decay_timer = Timer.new()
	magnum_opus_decay_timer.one_shot = false
	magnum_opus_decay_timer.autostart = true
	magnum_opus_decay_timer.timeout.connect(process_magnum_opus_decay_opportunity)
	refresh_magnum_opus_timer(starting_speed)
	add_child(magnum_opus_decay_timer)
	
	cubic_decay_timer = Timer.new()
	cubic_decay_timer.one_shot = false
	cubic_decay_timer.autostart = true
	cubic_decay_timer.timeout.connect(process_cubic_decay_opportunity)
	refresh_cubic_timer(starting_speed)
	add_child(cubic_decay_timer)
	
	slow_decay_timer = Timer.new()
	slow_decay_timer.timeout.connect(process_slow_decay_opportunity)
	refresh_slow_timer(starting_speed)
	add_child(slow_decay_timer)
	
	progress_ratio = 1.0
	health_bar._initialize_health_bar(health)

func _on_refresh_decay_timers(game_speed):
	refresh_decay_timer(game_speed)
	refresh_magnum_opus_timer(game_speed)
	refresh_cubic_timer(game_speed)
	refresh_slow_timer(game_speed)

func refresh_decay_timer(game_speed):

	if game_speed == 0.0:
		glow_decay_timer.paused = true
		return
	glow_decay_timer.paused = false
	glow_decay_timer.wait_time = 10.0 * (1/game_speed)

func refresh_magnum_opus_timer(game_speed):

	if game_speed == 0.0:
		magnum_opus_decay_timer.paused = true
		return
	magnum_opus_decay_timer.paused = false
	magnum_opus_decay_timer.wait_time = 2.0 * (1/game_speed)

func refresh_cubic_timer(game_speed):
	
	if game_speed == 0.0:
		cubic_decay_timer.paused = true
		return
	cubic_decay_timer.paused = false
	cubic_decay_timer.wait_time = 0.5 * (1/game_speed)

func refresh_slow_timer(game_speed):

	if game_speed == 0.0:
		slow_decay_timer.paused = true
		return
	slow_decay_timer.paused = false
	slow_decay_timer.wait_time = 0.2 * (1/game_speed)

func set_height_pos(offset:float):
	var original_enemy_area_pos = $enemy/enemy_mesh/enemy_area.position
	var original_enemy_multi_hit_area = $enemy/enemy_mesh/multi_hit_area.position
	var current_pos = $enemy.position
	var new_pos = Vector3(current_pos.x,offset,current_pos.z) 
	$enemy.set_original_position(new_pos)
	$enemy/enemy_mesh/enemy_area.position = Vector3(0,(-1*offset),0)  
	$enemy/enemy_mesh/multi_hit_area.position = Vector3(0,(-1*offset),0)  

func update_values_by_enemy_spawn_data(enemy_spawn_data:EnemySpawnData):
	speed = enemy_spawn_data.speed
	health = enemy_spawn_data.health
	damage_on_hit = enemy_spawn_data.damage_on_hit
	exp_on_kill = enemy_spawn_data.exp_on_kill
	enemy_scale_value = enemy_spawn_data.enemy_size_scale
	primary_color = enemy_spawn_data.primary_color
	highlight_color = enemy_spawn_data.highlight_color
	height_offset = enemy_spawn_data.height_offset

func update_model_color():

	model.set_enemy_primary_color(primary_color)
	model.set_enemy_highlight_color(highlight_color)

func update_model_scale():
	enemy_model_controller.scale = Vector3(enemy_scale_value,enemy_scale_value,enemy_scale_value)
	ui_origin.scale = Vector3(enemy_scale_value,enemy_scale_value,enemy_scale_value)
	ui_origin.position = Vector3(0,(enemy_scale_value),0)
	set_height_pos(height_offset)
	
func set_model_scale(_scale:float):
	var new_scale = Vector3(_scale,_scale,_scale)
	enemy_model_controller.scale = new_scale

func get_multi_hit_target():
	return multi_hit_targets.pick_random()

func has_multi_hit_target():
	return !multi_hit_targets.is_empty()

func set_slow(is_slowed:bool):
	is_slow = is_slowed
	if is_slowed:
		if ticker.get_cubic_count() > 0:
			slowness = 4
		else:
			slowness = 2
	else:
		slowness = 1

func apply_glowing_stack(stack_count:int):
	if ticker.get_cubic_count() > 0:
		stack_count *= 4
	ticker.increment_glowing(stack_count)

func apply_magnum_opus_stack(stack_count:int):
	if ticker.get_cubic_count() > 0:
		stack_count *= 4
	ticker.increment_magnum_opus(stack_count)

func apply_slow_stack(stack_count:int):
	ticker.increment_slow(stack_count)
	set_slow(true)
	slow_decay_timer.start()
	
func apply_cubic_stack(stack_count:int):
	ticker.increment_cubic(stack_count)
	cubic_decay_timer.start()

func calculate_crit_chance(stacks):
	var chance = min(1.0, base_crit_rate + (stacks * crit_increase_per_stack))
	return chance 

func take_damage(damage:float,multi_hit_proc_chance:float,wiggle_direction:Vector3):
	health = health - calculate_damage(damage)
	if is_criting:
		print("crit hit")
		GlobalAudio.play_enemy_hit()
		$enemy/model_scaler/enemy_model.damage_flash()
		$enemy.damage_wiggle(wiggle_direction,true)
		is_criting = false
	else:
		GlobalAudio.play_enemy_hit()
		$enemy/model_scaler/enemy_model.damage_flash()
		$enemy.damage_wiggle(wiggle_direction,false)
	
	health_bar.set_value(health)
	if process_multi_hit(multi_hit_proc_chance) and !multi_hit_targets.is_empty():
		var bullet = projectile.instantiate()
		bullet.set_target(multi_hit_targets.pick_random())
		bullet.set_damage(damage)
		bullet.set_multi_hit_proc_chance(multi_hit_proc_chance - 0.2)
		bullet.set_starting_position(global_position)
		get_parent().add_child(bullet)

func process_multi_hit(chance:float):
	if chance >= 1.0:
		return true
	else:
		var random_number = randf_range(0.0,1.0)
		if chance >= random_number:
			return true
		return false
	
func calculate_damage(damage:float):
	var calculated_damage
	var crit_chance = calculate_crit_chance(ticker.get_glowing_count())
	var random_chace = randf_range(0.0,1.0)
	if random_chace < crit_chance:
		calculated_damage = damage * 2.5
		is_criting = true
	else:
		calculated_damage = damage
	if ticker.get_cubic_count() > 0:
		calculated_damage *= 4
	return calculated_damage

func _process(delta):

	progress = (progress - ((speed/slowness) * delta) * GameMode.get_global_game_speed())
	if health <= 0:
		emit_signal("enemy_killed", exp_on_kill,enemy_uuid)
		self.queue_free()
	if progress <= 0:
		emit_signal("reached_the_center",damage_on_hit,enemy_uuid)
		self.queue_free()

func process_glowing_decay_opportunity():
	apply_glowing_stack(-1)
	glow_decay_timer.start()
	
func process_magnum_opus_decay_opportunity():
	if ticker.get_magnum_opus_count() > 0:
		apply_magnum_opus_stack(-1)
		take_damage(ticker.get_magnum_opus_count(),0.0,Vector3(0,0,0))
		

func process_cubic_decay_opportunity():
	apply_cubic_stack(-1)


func process_slow_decay_opportunity():
	apply_slow_stack(-1)
	set_slow(false)


func _on_multi_hit_area_entered(area):
	if area.get_name() == "enemy_area":
		multi_hit_targets.append(area)

func _on_multi_hit_area_exited(area):
	if multi_hit_targets.has(area):
		multi_hit_targets.erase(area)
