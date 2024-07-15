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

#_init(_health:float,_speed:float,_exp:float,_damage:int,_spawn_time:int):EnemySpawnData constructor

func load_enemy_spawn_data_by_type(type:negative_vibes):
	var enemy_spawn_data
	match type:
		negative_vibes.ANXIETY:
			enemy_spawn_data = EnemySpawnData.new(100,0.01,1,1,2000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("anxiety")
		negative_vibes.FEAR:
			enemy_spawn_data = EnemySpawnData.new(1,1,1,1,1000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("fear")
		negative_vibes.ANGER:
			enemy_spawn_data = EnemySpawnData.new(1,1,1,1,1000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("anger")
		negative_vibes.SADNESS:
			enemy_spawn_data = EnemySpawnData.new(1,1,1,1,1000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("sadness")
		negative_vibes.CONTEMPT:
			enemy_spawn_data = EnemySpawnData.new(1,1,1,1,1000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("contempt")
		negative_vibes.ENVY:
			enemy_spawn_data = EnemySpawnData.new(1,1,1,1,1000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("envy")
		negative_vibes.DESPAIR:
			enemy_spawn_data = EnemySpawnData.new(1,1,1,1,1000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("despair")
		negative_vibes.SHAME:
			enemy_spawn_data = EnemySpawnData.new(1,1,1,1,1000)
			enemy_spawn_data_array.append(enemy_spawn_data)
			#print("shame")
		

func get_enemy_spawn_data_array_by_level(level:int):
	#clear the array of enemy info
	enemy_spawn_data_array.clear()
	#add enemies based on level and modifiers
	load_enemy_spawn_data_by_type(negative_vibes.ANXIETY)

	#print(level)

	#print("array loaded")
	
	return enemy_spawn_data_array.duplicate(true)

func reset_game_data():
	is_fresh_reset = true
	
func check_is_reset():
	if is_fresh_reset:
		is_fresh_reset = false
		return true
	else:
		return false
	
