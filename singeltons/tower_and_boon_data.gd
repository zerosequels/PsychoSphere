extends Node

var growth_rate = 0.2
var range_visibility_mode_toggled = false

signal increase_currency(exp)
signal unlock_tower(tower_type)
signal refresh_card_cost()
signal memo_content_loaded

var currently_selected_tower_type = -1

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

enum boost_types {
	notice,
	insight,
	paradigm,
	vision,
	gnosis
}

const tier_1_keys = [
	"big pharma",
	"atlantis",
	"mandela effect",
	"new world order",
	"orbs",
	"nibiru",
	"antarctica",
	"operation northwoods",
	"psyops",
	"majestic twelve"
]

const tier_2_keys = [
	"lucid dreaming",
	"flourid effect",
	"mk ultra",
	"pineal gland",
	"agartha",
	"HAARP",
	"astral projection",
	"sucubii",
	"eastern esotericism",
	"nephilim",
	"the missing cosmonauts",
	"dyatlov pass",
	"tulpas",
	"operation blue beam",
	"occult knowledge",
	"magicka",
	"space is fake",
	"divination",
	"pantheism",
	"archdemons/angels",
	"philosopher's stone",
	"my red is not your red",
	"vampires",
	"aura",
	"bohemian grove",
	"lost civilizations",
	"paranormal beings",
	"gangstalking",
	"experiments on humans",
	"6th extinction",
	"pseudosciences",
	"saturn's rings",
	"polar shift",
	"large hadron collider",
	"oumuamua",
	"fish rain",
	"elite politician body doubles",
	"butterfly effect",
	"ningens",
	"oil pit squid",
	"lemuria and mount shasta",
	"crystal skulls"
]

const tier_3_keys = [
	"singularity",
	"quantum suicide and immortality",
	"pleroma",
	"archons",
	"sacred geometry",
	"DMT beings",
	"thule",
	"toxoplasmosis effect on the human brain",
	"titanic was sunk to create the federal reserve",
	"smithsonian suppresses evidence of giants",
	"tartaria",
	"panspermia",
	"grey goo",
	"fullcanelli"
]

const tier_4_keys = [
	"dogon tribe",
	"lord pakal's time machine",
	"pesticides and the american food supply",
	"vimana",
	"washington dc street plan designed by freen masons",
	"grand unified conspiracy theory",
	"baltic sea anomaly",
	"Nimrod control system",
	"global depopulation",
	"holotropic breathworks",
	"hermeticism",
	"negative-entropy",
	"nexus 7",
	"geometrodynamics",
	"cave dweller holocaust",
	"dolphin intelligence",
	"himalayan zombies (rolang)",
	"deep philosophies/ hermenuetics",
	"mirl cults",
	"toronto protocol",
	"presentism",
	"bootes void",
	"plant intelligence",
	"last thursdayism",
	"acosmism",
	"abiogenic oil",
	"secret societies today",
	"prison planet",
	"malta catacombs",
	"patomskiy crater",
	"animism",
	"montanism",
	"operation paper clip"
]

const tier_5_keys = [
	"magic of the state",
	"sycamore knoll underwater alien base",
	"reactionless drive",
	"enneagram",
	"protodite",
	"accoustic attacks",
	"panopticon",
	"prana release",
	"corporate kill list",
	"interdimensional bigfoot",
	"ghost condensate",
	"organic black helicopters",
	"breatharianism",
	"psychotropic warfare",
	"All of human history is fake",
	"object oriented ontology",
	"accelerationism",
	"omphalos",
	"quantum entanglement",
	"kundalini energy",
	"brain in a jar",
	"symbiogenesis",
	"antikythera mechanism",
	"anatta",
	"polywater",
	"human genome projects true purpose"
]

const tier_6_keys = [
	#"bogandoff twins are powerful psychic archangle superhumans who will usher in an age of genetic engineering",
	"dead internet theory",
	"quantum computers are trapped demonic entities",
	"subjective reality",
	"spiritual microeconomy",
	"the american government fought the iraq war to secure the tomb of gilgamesh",
	"synchronicity",
	"dream hacking",
	"S EN",
	"captivity suburbs",
	"kali yuga describes an inevitable cycle of moral decay and corruption leading to heroic destruction and a restoriation of morality that all societies eventually go through",
	"torsion fields",
	"morphic field",
	"genepool financialization",
	"The universe is a hologram"
]

const tier_7_keys = [
	"hypersigils",
	"amazon rainforrest was built by an ancient society",
	"akashic records",
	"classical metaphysics",
	"annunaki created humans to mine gold",
	"soy products are weaponized aginst the public to make them have less testosterone and therefore more agreeable to government control",
	"bicameralism of the human brain, ancient people could hear the voices of gods",
	"The true purpose of the great pyramind",
	"moon built by aliens",
	"field conciousness",
	"humanity shares a flood myth",
	"non-space"
]

const tier_8_keys = [
	"timecube",
	"wetiko",
	"the nephelim looked like clowns",
	"deep soy, xeno estrogens",
	"eating food makes you age",
	"wars are started on purpose for the sake of profit",
	"microchips found in fossils"
]

const tier_9_keys = [
	"retrocausality",
	"ancient egypt was advanced and the sphinx was eroded by water ina great flood",
	"phlogiston theory resurfacing",
	"nano-ufos and giga-ufos",
	"regenerative death consumption",
	"thoth was an alchemist and a high preist in ancient atlantis",
	"secret human potential"
]

const tier_10_keys = [
	"oikeiosis",
	"fractialization",
	"god's ego death",
	"all conspiracies are true",
	"gods last wish was for humans to have free will",
	"There is no conspiracy",
	"The final understanding"
]

var memo_content = {}

func _ready():
	var json_text = FileAccess.get_file_as_string("res://data/memo_content.json")
	var parsed = JSON.parse_string(json_text)
	if parsed == null:
		return
	memo_content = parsed
	emit_signal("memo_content_loaded")

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

var boost_type_array = [
	0,1,2,3,4
]

func get_boon_type():
	if locked_towers.is_empty():
		return boon_types.boost
	return boon_types.tower

func get_random_tower_to_unlock():
	var tower_to_unlock = locked_towers.pick_random()
	return tower_to_unlock

func get_random_boost():
	var boost = boost_type_array.pick_random()
	return boost

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
			return "inflicts cubic time debuff on all enemies in range, enemies with cubic time multiply all damage taken by four"
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

func get_boost_description_by_boost_type(boost_type):
	match boost_type:
		boost_types.notice:
			return "[+$$$25]
			You've noticed a pattern "
		boost_types.insight:
			return "[+$$$50]
			You've connected the dots "
		boost_types.paradigm:
			return "[+$$$75]
			You've opened a new eye through which to see "
		boost_types.vision:
			return "[+$$$100]
			Source? It was revealed to me in a dream "
		boost_types.gnosis:
			return "[+$$$150]
			The ultimate final truth is within your grasp "

func get_boost_name_by_boost_type(boost_type):
	match boost_type:
		boost_types.notice:
			return "notice"
		boost_types.insight:
			return "insight"
		boost_types.paradigm:
			return "paradigm"
		boost_types.vision:
			return "vision"
		boost_types.gnosis:
			return "gnosis"

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
			return load("res://assets/tilesets/card_forkl.png")
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

#refactor these two methods to utilize a third cost estimator and then use that to determine price from count

func get_tower_cost_by_count_and_type(count:int,base_cost:int):
	var cost = base_cost * (1 + count + growth_rate)
	return int(cost)

func get_next_tower_price_and_increment_count(type:tower_types):
	var count = tower_type_count[type]
	var base_cost = get_tower_base_cost(type)
	var new_cost = get_tower_cost_by_count_and_type(count,base_cost)
	count = count + 1
	tower_type_count[type] = count
	return new_cost

func get_next_tower_price(tower_type:tower_types):
	if tower_type == 13:
		return -1
	var count = tower_type_count[tower_type]
	var base_cost = get_tower_base_cost(tower_type)
	var new_cost = get_tower_cost_by_count_and_type(count,base_cost)
	return new_cost

func increase_awareness_by_boost_type(new_boon_id):
	match new_boon_id:
		boost_types.notice:
			increase_awarness(25)
		boost_types.insight:
			increase_awarness(50)
		boost_types.paradigm:
			increase_awarness(75)
		boost_types.vision:
			increase_awarness(100)
		boost_types.gnosis:
			increase_awarness(150)

func refund_tower_by_type(type:tower_types):
	var count = tower_type_count[type]
	count = count - 1
	var base_cost = get_tower_base_cost(type)
	var new_cost = get_tower_cost_by_count_and_type(count,base_cost)
	tower_type_count[type] = count
	increase_awarness(new_cost)

func refund_tower_by_price(price:int):
	increase_awarness(price)
	
func refund_tower_by_price_and_type(price:int,type:tower_types):
	increase_awarness(price)
	tower_type_count[type] = tower_type_count[type] - 1
	emit_signal("refresh_card_cost")

func get_tower_base_cost(tower_type:tower_types):
	match tower_type:
		tower_types.ANKH:
			return 1
		tower_types.PYRAMID:
			return 1
		tower_types.THIRD_EYE:
			return 5
		tower_types.SPIRAL:
			return 1
		tower_types.FLOWER_OF_LIFE:
			return 1
		tower_types.EMERALD_TABLET:
			return 1
		tower_types.PRAYER_WHEEL:
			return 5
		tower_types.TIME_CUBE:
			return 10
		tower_types.TUNING_FORK:
			return 1
		tower_types.DEATH_FUNGUS:
			return 5
		tower_types.RUBEDO:
			return 5
		tower_types.COSMIC_EGG:
			return 5
		tower_types.ANNUNAKI_WEAPON:
			return 5

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

func reset_tower_and_boon_data():
	unlocked_towers = [
	tower_types.PYRAMID
	]
	locked_towers = [
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
	tower_type_count = {	
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

func get_currently_selected_tower():
	return currently_selected_tower_type
	
func set_currently_selected_tower(index):
	currently_selected_tower_type = index

func get_memo_content():
	return memo_content
