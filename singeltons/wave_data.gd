extends Node

enum negative_vibes {
	#Default weak unit
	ANXIETY,
	#Moves quickly but has less health
	FEAR,
	#Moves normally but does more damage
	ANGER,
	#Moves slowly and has armor
	SADNESS,
	#Causes other negative vibes to move a little faster when in the AOE
	CONTEMPT,
	#Other enemies in the AOE can't be targeted until this one is killed, and has health and shield
	ENVY,
	#SHIELD AND ARMOR, but no health, slow
	DESPAIR,
	#more health, more speed
	SHAME
}

var max_enemy_limit = 25

var early_game = 25

var early_enemies = [0,1,2]
var mid_enemies = [3,4,5]
var late_enemies = [6,7]

var mid_game = 50
var late_game = 75

var enemy_spawn_data_array = []
var is_fresh_reset = false

var active_enemy_array = []
var total_number_of_waves = 0

var trigger_id_dict = {}

#(_health:float,_speed:float,_exp:float,_damage:int,_spawn_time:int):EnemySpawnData constructor
func load_enemy_spawn_data_by_type(type:negative_vibes):
	var enemy_spawn_data
	match type:
		negative_vibes.ANXIETY:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(3)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1.75)
			enemy_spawn_data.set_spawn_time(1000)
			enemy_spawn_data.set_enemy_size_scale(0.5)
			enemy_spawn_data.set_primary_color(Color.SPRING_GREEN)
			enemy_spawn_data.set_highlight_color(Color.DARK_GREEN)
			enemy_spawn_data.set_height_offset(-0.3)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("anxiety")
		negative_vibes.FEAR:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(5)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(2)
			enemy_spawn_data.set_speed(5)
			enemy_spawn_data.set_spawn_time(1000)
			enemy_spawn_data.set_enemy_size_scale(0.25)
			enemy_spawn_data.set_primary_color(Color.YELLOW)
			enemy_spawn_data.set_highlight_color(Color.ORANGE)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("fear")
		negative_vibes.ANGER:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(5)
			enemy_spawn_data.set_damage(5)
			enemy_spawn_data.set_exp(10)
			enemy_spawn_data.set_speed(1.5)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.CRIMSON)
			enemy_spawn_data.set_highlight_color(Color.DEEP_PINK)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("anger")
		negative_vibes.SADNESS:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(8)
			enemy_spawn_data.set_damage(5)
			enemy_spawn_data.set_exp(15)
			enemy_spawn_data.set_speed(1.5)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(2)
			enemy_spawn_data.set_primary_color(Color.DODGER_BLUE)
			enemy_spawn_data.set_highlight_color(Color.SLATE_BLUE)
			enemy_spawn_data.set_height_offset(0.3)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("sadness")
		negative_vibes.CONTEMPT:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(15)
			enemy_spawn_data.set_exp(10)
			enemy_spawn_data.set_speed(3)
			enemy_spawn_data.set_spawn_time(3000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.CORNSILK)
			enemy_spawn_data.set_highlight_color(Color.DIM_GRAY)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("contempt")
		negative_vibes.ENVY:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(10)
			enemy_spawn_data.set_exp(10)
			enemy_spawn_data.set_speed(3.75)
			enemy_spawn_data.set_spawn_time(1000)
			enemy_spawn_data.set_enemy_size_scale(0.75)
			enemy_spawn_data.set_primary_color(Color.FUCHSIA)
			enemy_spawn_data.set_highlight_color(Color.GREEN_YELLOW)
			enemy_spawn_data.set_height_offset(-0.2)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("envy")
		negative_vibes.DESPAIR:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(10)
			enemy_spawn_data.set_exp(100)
			enemy_spawn_data.set_speed(1.5)
			enemy_spawn_data.set_spawn_time(5000)
			enemy_spawn_data.set_enemy_size_scale(2.5)
			enemy_spawn_data.set_primary_color(Color.MIDNIGHT_BLUE)
			enemy_spawn_data.set_highlight_color(Color.MEDIUM_BLUE)
			enemy_spawn_data.set_height_offset(0.75)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("despair")
		negative_vibes.SHAME:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(5)
			enemy_spawn_data.set_damage(5)
			enemy_spawn_data.set_exp(5)
			enemy_spawn_data.set_speed(5)
			enemy_spawn_data.set_spawn_time(500)
			enemy_spawn_data.set_enemy_size_scale(0.5)
			enemy_spawn_data.set_primary_color(Color.STEEL_BLUE)
			enemy_spawn_data.set_highlight_color(Color.SKY_BLUE)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("shame")
		

func set_total_number_of_waves(_total_number):
	total_number_of_waves = _total_number

#this method is depreciated
func get_enemy_spawn_data_array_by_level(level:int):
	#clear the array of enemy info
	enemy_spawn_data_array.clear()
	
	#add enemies based on level and modifiers
	
	for x in level + total_number_of_waves:
		load_enemy_spawn_data_by_type(negative_vibes.ANXIETY)
	if total_number_of_waves % 5 == 0:
		load_enemy_spawn_data_by_type(negative_vibes.ANGER)

	#load_enemy_spawn_data_by_type(negative_vibes.ANXIETY)
	#load_enemy_spawn_data_by_type(negative_vibes.FEAR)
	#load_enemy_spawn_data_by_type(negative_vibes.ANGER)
	#load_enemy_spawn_data_by_type(negative_vibes.SADNESS)
	#load_enemy_spawn_data_by_type(negative_vibes.CONTEMPT)
	#load_enemy_spawn_data_by_type(negative_vibes.ENVY)
	#load_enemy_spawn_data_by_type(negative_vibes.DESPAIR)
	#load_enemy_spawn_data_by_type(negative_vibes.SHAME)
	
	return enemy_spawn_data_array.duplicate(true)

func add_enemies_to_queue_by_trigger_id(trigger_id):
	if !trigger_id_dict.has(trigger_id):
		print("creating trigger_id array for %s." % trigger_id)
		trigger_id_dict[trigger_id] = [0,0,0]
	var path_enemy_array = trigger_id_dict[trigger_id]
	#if less than max enemies then add from bucket
	if path_enemy_array.size() < max_enemy_limit:
		path_enemy_array.append(early_enemies.pick_random())
	else:
		var enemy_to_upgrade
		var index = randi_range(0,path_enemy_array.size() - 1)
		enemy_to_upgrade = path_enemy_array.pop_at(index)
		var chance_to_upgrade = randi_range(0,1)
		if chance_to_upgrade == 1:
			#if is early enemy -> convert to mid game enemy 
			if early_enemies.has(enemy_to_upgrade):
				enemy_to_upgrade = mid_enemies.pick_random()
			#if mid -> convert to late game enemy
			elif mid_enemies.has(enemy_to_upgrade):
				enemy_to_upgrade = late_enemies.pick_random()
		path_enemy_array.insert(index,enemy_to_upgrade)
	

		
	trigger_id_dict[trigger_id] = path_enemy_array
		
		

func get_enemy_spawn_data_array_by_trigger_id(trigger_id):
	enemy_spawn_data_array.clear()
	
	#if the trigger_id_dict doesn't have the trigger id create a new enemy spawning array for it
	if !trigger_id_dict.has(trigger_id):
		print("creating trigger_id array for %s." % trigger_id)
		trigger_id_dict[trigger_id] = [0,0,0]

	for enemy_type in trigger_id_dict[trigger_id]:
		load_enemy_spawn_data_by_type(enemy_type)
		
	return enemy_spawn_data_array.duplicate(true)

func reset_game_data():
	is_fresh_reset = true
	active_enemy_array.clear()
	total_number_of_waves = 0
	trigger_id_dict.clear()
	GameMode.reset_global_game_speed()
	
func check_is_reset():
	if is_fresh_reset:
		is_fresh_reset = false
		return true
	else:
		return false

func is_active_enemy_array_empty():
	return active_enemy_array.is_empty()

func register_enemy_to_active_enemy_array(enemy):
	active_enemy_array.append(enemy)

func remove_enemy_by_uuid(uuid:int):
	for x in active_enemy_array:
		if x.enemy_uuid == uuid:
			if active_enemy_array.has(x):
				active_enemy_array.erase(x)
