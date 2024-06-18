extends Node

var growth_rate = 0.2
var range_visibility_mode_toggled = false


enum tower_types {
	#simple turret that shoots bullets
	PYRAMID,
	#Applies a DOT effect to focused enemy
	THIRD_EYE,
	#Creates a pulse of holy energy that damages enemies in a AOE radius
	ANKH,
	#Fires bullets that do splash damage
	SPIRAL,
	#Gives nearby towers splash damage
	FLOWER_OF_LIFE,
	#Gives nearby towers DOT effect
	EMERALD_TABLET,
	#Increases attack speed of neighboring towers
	PRAYER_WHEEL,
	#Slows enemies in a pulse
	TIME_CUBE,
	#chain damage chance to nearby towers
	TUNING_FORK,
	#If an enemy dies within a certain radius of this it will give a boost to all nearby towers
	DEATH_FUNGUS,
	#takes a long time to fire but has great range
	RUBEDO,
	#takes time to spawn a phoenix which will do damage flying around the map
	COSMIC_EGG,
	#summons meteors 
	ANNUNAKI_WEAPON
}

var tower_type_count = {	
	tower_types.PYRAMID:0,
	tower_types.THIRD_EYE:0,
	tower_types.ANKH:0,
	tower_types.SPIRAL:0,
	tower_types.FLOWER_OF_LIFE:0,
	tower_types.EMERALD_TABLET:0,
	tower_types.PRAYER_WHEEL:0,
	tower_types.TIME_CUBE:0,
	tower_types.TUNING_FORK:0,
	tower_types.DEATH_FUNGUS:0,
	tower_types.RUBEDO:0,
	tower_types.COSMIC_EGG:0,
	tower_types.ANNUNAKI_WEAPON:0
}

func get_is_range_visibility_mode_toggled():
	return range_visibility_mode_toggled
	
func set_range_visibility_mode(should:bool):
	range_visibility_mode_toggled = should

func get_next_tower_price_and_increment_count(type:tower_types):
	var count = tower_type_count[type]
	var new_cost
	if count == 0:
		new_cost = get_tower_base_cost(type)
	else:
		var base_cost = get_tower_base_cost(type)
		new_cost = base_cost * (1 + count + growth_rate)
	#increment count at end
	count = count + 1
	tower_type_count[type] = count
	return new_cost



func get_tower_base_cost(tower_type:tower_types):
	match tower_type:
		tower_types.ANKH:
			return 9
		tower_types.PYRAMID:
			return 3
		tower_types.THIRD_EYE:
			return 33
		tower_types.SPIRAL:
			return 5
		tower_types.FLOWER_OF_LIFE:
			return 12
		tower_types.EMERALD_TABLET:
			return 31
		tower_types.PRAYER_WHEEL:
			return 20
		tower_types.TIME_CUBE:
			return 44
		tower_types.TUNING_FORK:
			return 42
		tower_types.DEATH_FUNGUS:
			return 30
		tower_types.RUBEDO:
			return 99
		tower_types.COSMIC_EGG:
			return 72
		tower_types.ANNUNAKI_WEAPON:
			return 69

func get_tower_name(tower_type:tower_types):
	match tower_type:
		tower_types.ANKH:
			return "Ankh"
		tower_types.PYRAMID:
			return "Pyramid"
		tower_types.THIRD_EYE:
			return "Third Eye"
		tower_types.SPIRAL:
			return "Spiral"
		tower_types.FLOWER_OF_LIFE:
			return "Flower of Life"
		tower_types.EMERALD_TABLET:
			return "Emerald Tablet"
		tower_types.PRAYER_WHEEL:
			return "Prayer Wheel"
		tower_types.TIME_CUBE:
			return "Time Cube"
		tower_types.TUNING_FORK:
			return "Tuning Fork"
		tower_types.DEATH_FUNGUS:
			return "Death Fungus"
		tower_types.RUBEDO:
			return "The Magnum Opus"
		tower_types.COSMIC_EGG:
			return "Cosmic Egg"
		tower_types.ANNUNAKI_WEAPON:
			return "Akkashik truth bomb"






