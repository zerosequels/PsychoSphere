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

var enemy_spawn_data_array = []
var is_fresh_reset = false

var active_enemy_array = []


#(_health:float,_speed:float,_exp:float,_damage:int,_spawn_time:int):EnemySpawnData constructor
func load_enemy_spawn_data_by_type(type:negative_vibes):
	var enemy_spawn_data
	match type:
		negative_vibes.ANXIETY:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(3)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(0.5)
			enemy_spawn_data.set_spawn_time(1000)
			enemy_spawn_data.set_enemy_size_scale(0.25)
			enemy_spawn_data.set_primary_color(Color.SPRING_GREEN)
			enemy_spawn_data.set_highlight_color(Color.DARK_GREEN)
			enemy_spawn_data.set_height_offset(-0.3)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("anxiety")
		negative_vibes.FEAR:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.ORANGE)
			enemy_spawn_data.set_highlight_color(Color.YELLOW)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("fear")
		negative_vibes.ANGER:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.CRIMSON)
			enemy_spawn_data.set_highlight_color(Color.DEEP_PINK)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("anger")
		negative_vibes.SADNESS:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.DODGER_BLUE)
			enemy_spawn_data.set_highlight_color(Color.BLUE_VIOLET)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("sadness")
		negative_vibes.CONTEMPT:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.WEB_GRAY)
			enemy_spawn_data.set_highlight_color(Color.TURQUOISE)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("contempt")
		negative_vibes.ENVY:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.DARK_CYAN)
			enemy_spawn_data.set_highlight_color(Color.DARK_GREEN)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("envy")
		negative_vibes.DESPAIR:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.MEDIUM_BLUE)
			enemy_spawn_data.set_highlight_color(Color.MIDNIGHT_BLUE)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("despair")
		negative_vibes.SHAME:
			enemy_spawn_data = EnemySpawnData.new()
			enemy_spawn_data.set_health(10)
			enemy_spawn_data.set_damage(1)
			enemy_spawn_data.set_exp(1)
			enemy_spawn_data.set_speed(1)
			enemy_spawn_data.set_spawn_time(2000)
			enemy_spawn_data.set_enemy_size_scale(1)
			enemy_spawn_data.set_primary_color(Color.STEEL_BLUE)
			enemy_spawn_data.set_highlight_color(Color.SKY_BLUE)
			
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("shame")
		

func get_enemy_spawn_data_array_by_level(level:int):
	#clear the array of enemy info
	enemy_spawn_data_array.clear()
	#add enemies based on level and modifiers
	load_enemy_spawn_data_by_type(negative_vibes.ANGER)
	load_enemy_spawn_data_by_type(negative_vibes.ANXIETY)
	#load_enemy_spawn_data_by_type(negative_vibes.CONTEMPT)
	#load_enemy_spawn_data_by_type(negative_vibes.DESPAIR)
	#load_enemy_spawn_data_by_type(negative_vibes.ENVY)
	#load_enemy_spawn_data_by_type(negative_vibes.FEAR)
	#load_enemy_spawn_data_by_type(negative_vibes.SHAME)
	#load_enemy_spawn_data_by_type(negative_vibes.SADNESS)

	
	
	return enemy_spawn_data_array.duplicate(true)

func reset_game_data():
	is_fresh_reset = true
	
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
			active_enemy_array.erase(x)
