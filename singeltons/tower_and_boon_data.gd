extends Node

var growth_rate = 0.2
var range_visibility_mode_toggled = false

signal increase_currency(exp)
signal unlock_tower(tower_type)

var unlocked_towers = [
	tower_types.PYRAMID
]

var locked_towers = [
	tower_types.ANKH,
	tower_types.ANNUNAKI_WEAPON,
	tower_types.COSMIC_EGG,
	tower_types.DEATH_FUNGUS,
	tower_types.EMERALD_TABLET,
	tower_types.FLOWER_OF_LIFE,
	tower_types.PRAYER_WHEEL,
	tower_types.RUBEDO,
	tower_types.SPIRAL,
	tower_types.THIRD_EYE,
	tower_types.TIME_CUBE,
	tower_types.TUNING_FORK
]

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

enum boon_types {
	unlock,
	boost,
	tower,
	out_of_boons
}

var boon_type_array = [
	boon_types.unlock,
	boon_types.boost,
	boon_types.tower,
	boon_types.out_of_boons
]

func get_boon_type():
	if locked_towers.is_empty():
		return boon_types.out_of_boons
	return boon_types.tower

func get_random_tower_to_unlock():
	var tower_to_unlock = locked_towers.pick_random()
	return tower_to_unlock

func unlock_tower_by_tower_type(tower_type):
	locked_towers.erase(tower_type)
	unlocked_towers.append(tower_type)
	emit_signal("unlock_tower",tower_type)

func get_tower_unlock_description_by_tower_type(tower_type):
	match tower_type:
		tower_types.ANKH:
			return "deals aoe damage to enemies within the ankh's range"
		tower_types.PYRAMID:
			return "fires volleys of energy at enemies damaging them on hit"
		tower_types.THIRD_EYE:
			return "illuminates enemies causing them to take extra damage on hit per stack"
		tower_types.SPIRAL:
			return "increases the damage of nearby damage dealing towers"
		tower_types.FLOWER_OF_LIFE:
			return "nearby damage dealing towers now have an increased chance to chain damage other enemies on hit"
		tower_types.EMERALD_TABLET:
			return "increases the range of nearby towers including itself"
		tower_types.PRAYER_WHEEL:
			return "slows down the movement speed of all enemies within range"
		tower_types.TIME_CUBE:
			return "inflicts cubic time debuff on all enemies in range, enemies with cubic time will take four times the damage per hit and will be given four times the number of debuff stacks per debuff"
		tower_types.TUNING_FORK:
			return "increases the attack speed of nearby towers"
		tower_types.DEATH_FUNGUS:
			return "enemies that die within this towrs range will generate double the awarness"
		tower_types.RUBEDO:
			return "fires darts at all nearby enemies, applying damage over time stack on hit"
		tower_types.COSMIC_EGG:
			return "an egg that will grow until it hatches, birthing a galaxy that will richochete from enemy to enemy on hit"
		tower_types.ANNUNAKI_WEAPON:
			return "spawns a beam of light that tracks enemies and burns them over time"

func get_tower_unlock_texture_by_tower_type(tower_type):
	match tower_type:
		tower_types.ANKH:
			return load("res://assets/tilesets/card_ankh.png")
		tower_types.PYRAMID:
			return load("res://assets/tilesets/pyramid_card.png")
		tower_types.THIRD_EYE:
			return load("res://assets/tilesets/third_eye_card.png")
		tower_types.SPIRAL:
			return load("res://assets/tilesets/card_spiral.png")
		tower_types.FLOWER_OF_LIFE:
			return load("res://assets/tilesets/fol.png")
		tower_types.EMERALD_TABLET:
			return load("res://assets/tilesets/emerald_tablet_cardl.png")
		tower_types.PRAYER_WHEEL:
			return load("res://assets/tilesets/mani_wheel_card.png")
		tower_types.TIME_CUBE:
			return load("res://assets/tilesets/card_timecubel.png")
		tower_types.TUNING_FORK:
			return load("res://assets/tilesets/card_spiral.png")
		tower_types.DEATH_FUNGUS:
			return load("res://assets/tilesets/fungusl_card.png")
		tower_types.RUBEDO:
			return load("res://assets/tilesets/magnum_opus_card.png")
		tower_types.COSMIC_EGG:
			return load("res://assets/tilesets/egg.png")
		tower_types.ANNUNAKI_WEAPON:
			return load("res://assets/tilesets/annunaki_card.png")




func get_tower_unlock_name_by_tower_type(tower_type):
	match tower_type:
		tower_types.ANKH:
			return "The Ankh"
		tower_types.PYRAMID:
			return "The Pyramid"
		tower_types.THIRD_EYE:
			return "The All Seeing Eye"
		tower_types.SPIRAL:
			return "Genetic Memories"
		tower_types.FLOWER_OF_LIFE:
			return "Sacred Geometry"
		tower_types.EMERALD_TABLET:
			return "Emerald Tablet"
		tower_types.PRAYER_WHEEL:
			return "Mani Wheel"
		tower_types.TIME_CUBE:
			return "TIME CUBE"
		tower_types.TUNING_FORK:
			return "Tuning Fork"
		tower_types.DEATH_FUNGUS:
			return "Cosmic Fungus"
		tower_types.RUBEDO:
			return "Philosopher's Stone"
		tower_types.COSMIC_EGG:
			return "Cosmic Egg"
		tower_types.ANNUNAKI_WEAPON:
			return "Annunaki Sun Dial"

func get_is_range_visibility_mode_toggled():
	return range_visibility_mode_toggled
	
func set_range_visibility_mode(should:bool):
	range_visibility_mode_toggled = should

func increase_awarness(exp:int):
	emit_signal("increase_currency",exp)

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
			return 1
		tower_types.PYRAMID:
			return 1
		tower_types.THIRD_EYE:
			return 1
		tower_types.SPIRAL:
			return 1
		tower_types.FLOWER_OF_LIFE:
			return 1
		tower_types.EMERALD_TABLET:
			return 1
		tower_types.PRAYER_WHEEL:
			return 1
		tower_types.TIME_CUBE:
			return 1
		tower_types.TUNING_FORK:
			return 1
		tower_types.DEATH_FUNGUS:
			return 1
		tower_types.RUBEDO:
			return 1
		tower_types.COSMIC_EGG:
			return 1
		tower_types.ANNUNAKI_WEAPON:
			return 1

func get_tower_name(tower_type:tower_types):
	match tower_type:
		tower_types.ANKH:
			return "Ankh"
		tower_types.PYRAMID:
			return "Pyramid"
		tower_types.THIRD_EYE:
			return "All Seeing Eye"
		tower_types.SPIRAL:
			return "Ancestral Memories"
		tower_types.FLOWER_OF_LIFE:
			return "Flower of Life"
		tower_types.EMERALD_TABLET:
			return "Emerald Tablet"
		tower_types.PRAYER_WHEEL:
			return "Mani Wheel"
		tower_types.TIME_CUBE:
			return "Time Cube"
		tower_types.TUNING_FORK:
			return "Tuning Fork"
		tower_types.DEATH_FUNGUS:
			return "Cosmic Fungus"
		tower_types.RUBEDO:
			return "The Magnum Opus"
		tower_types.COSMIC_EGG:
			return "Cosmic Egg"
		tower_types.ANNUNAKI_WEAPON:
			return "Annunaki Sun Dial"


