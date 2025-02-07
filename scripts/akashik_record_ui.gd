extends Control

signal memo_toggled(is_memo_visible: bool)

@export var button_scale = 1.0
@export var vertical_spacing = 100
@export_range(0.0, 1.0) var max_horizontal_ratio = 0.2  # Maximum ratio of screen width to offset (0-1)
@export var buttons_per_tier = 2  # Maximum buttons that can fit in one tier
@export var tier_height = 150  # Height of each tier
@export var tier_1_vertical_offset = -1350: set = update_vertical_offset  # Vertical offset for tier 1 group
@export var tier_2_vertical_offset = -550: set = update_tier_2_vertical_offset  # Vertical offset for tier 2 group
@export var tier_3_vertical_offset = 2800: set = update_tier_3_vertical_offset  # Vertical offset for tier 3 group
@export var tier_4_vertical_offset = 4050: set = update_tier_4_vertical_offset  # Vertical offset for tier 4 group
@export var tier_5_vertical_offset = 6525: set = update_tier_5_vertical_offset  # Vertical offset for tier 5 group
@export var tier_6_vertical_offset = 8385: set = update_tier_6_vertical_offset  # Vertical offset for tier 6 group
@export var tier_7_vertical_offset = 9555: set = update_tier_7_vertical_offset  # Vertical offset for tier 7 group
@export var tier_8_vertical_offset = 10550: set = update_tier_8_vertical_offset  # Vertical offset for tier 8 group
@export var tier_9_vertical_offset = 11065: set = update_tier_9_vertical_offset  # Vertical offset for tier 9 group
@export var tier_10_vertical_offset = 11550: set = update_tier_10_vertical_offset  # Vertical offset for tier 10 group

@onready var conspiracy_menu_button = preload("res://scenes/conspiracy_theory_button.tscn")
@onready var custom_font = preload("res://assets/ui/GelatinTTFCAPS.ttf")

var button_container: Control
var memo_panel: Panel
var memo_image: TextureRect
var memo_text: RichTextLabel
var memo_title: Label
var back_button: Button
var current_ui_offset = 0.0

var _base_positions = {}  # Store base positions of buttons

const SPACING_SEED = 12345
const SCREEN_MARGIN_RATIO = 0.05  # 5% of screen width
const MIN_BUTTON_SPACING = 50  # Minimum horizontal space between buttons
const MEMO_PANEL_SIZE = Vector2(800, 600)

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
	"gods last wish was for humans to have free will",
	"oikeiosis",
	"all conspiracies are true",
	"fractialization",
	"god's ego death",
	"There is no conspiracy",
	"The final understanding"
]

# Dictionary to store memo content for each conspiracy
const memo_content = {
	"big pharma": {
		"text": "The pharmaceutical industry controls global health through manufactured diseases and expensive treatments...",
		"image": "res://assets/textures/big_pharma.png",
		"name_override": "big pharma"
	},
	"atlantis": {
		"text": "An advanced civilization lost beneath the waves, possessing technology beyond our comprehension...",
		"image": "res://assets/textures/atlantis2.png",
		"name_override": "atlantis"
	},
	"mandela effect": {
		"text": "Collective false memories suggesting parallel universes or timeline manipulation...",
		"image": "res://assets/textures/mandela_effect_00005_.png",
		"name_override": "mandela effect"
	},
	"new world order": {
		"text": "A secret cabal of elite individuals controlling world events from the shadows...",
		"image": "res://assets/textures/new_world_order_2.png",
		"name_override": "new world order"
	},
	"orbs": {
		"text": "Mysterious spheres of light captured in photographs, believed to be supernatural entities...",
		"image": "res://assets/textures/orbs.png",
		"name_override": "orbs"
	},
	"nibiru": {
		"text": "A hidden planet on a collision course with Earth, covered up by world governments...",
		"image": "res://assets/textures/nibiru.png",
		"name_override": "nibiru"
	},
	"antarctica": {
		"text": "Ancient civilizations and secret military bases hidden beneath the ice...",
		"image": "res://assets/textures/antarctica_00005_.png",
		"name_override": "antarctica"
	},
	"operation northwoods": {
		"text": "Declassified government plans for false flag operations to justify military intervention...",
		"image": "res://assets/textures/northwoods.png",
		"name_override": "operation northwoods"
	},
	"psyops": {
		"text": "Psychological operations used to manipulate public perception and behavior...",
		"image": "res://assets/textures/psyops_00006_.png",
		"name_override": "psyops"
	},
	"majestic twelve": {
		"text": "A secret committee formed to investigate UFO activity and maintain public ignorance...",
		"image": "res://assets/textures/majestic_12.png",
		"name_override": "majestic twelve"
	},
	"lucid dreaming": {
		"text": "The ability to consciously control and manipulate dreams, possibly connecting to other dimensions...",
		"image": "res://assets/textures/lucid.png",
		"name_override": "lucid dreaming"
	},
	"flourid effect": {
		"text": "Mass fluoridation of water supplies as a means of population control and mental suppression...",
		"image": "res://assets/textures/flouride2.png",
		"name_override": "flourid effect"
	},
	"mk ultra": {
		"text": "CIA mind control experiments using drugs, hypnosis, and psychological manipulation...",
		"image": "res://assets/textures/mkultra.png",
		"name_override": "mk ultra"
	},
	"pineal gland": {
		"text": "The third eye, deliberately calcified to suppress humanity's natural psychic abilities...",
		"image": "res://assets/textures/flouride.png",
		"name_override": "pineal gland"
	},
	"agartha": {
		"text": "An advanced civilization living within the hollow Earth, accessible through secret polar entrances...",
		"image": "res://assets/textures/agartha.png",
		"name_override": "agartha"
	},
	"HAARP": {
		"text": "Weather control and mind manipulation through high-frequency electromagnetic waves...",
		"image": "res://assets/textures/haarp.png",
		"name_override": "haarp"
	},
	"astral projection": {
		"text": "The ability to separate consciousness from the physical body and travel through other dimensions...",
		"image": "res://assets/textures/astral_projection.png",
		"name_override": "astral projection"
	},
	"sucubii": {
		"text": "Interdimensional entities that feed on human life force through dream manipulation...",
		"image": "res://assets/textures/sucubii.png",
		"name_override": "sucubii"
	},
	"eastern esotericism": {
		"text": "Ancient mystical knowledge suppressed by modern society and religious institutions...",
		"image": "res://assets/textures/eastern_esotericism.png",
		"name_override": "eastern esotericism"
	},
	"nephilim": {
		"text": "Giant hybrid beings born from the union of fallen angels and humans...",
		"image": "res://assets/textures/nephilim.png",
		"name_override": "nephilim"
	},
	"the missing cosmonauts": {
		"text": "Lost Soviet space missions covered up to maintain the appearance of space program success...",
		"image": "res://assets/textures/cosmo.png",
		"name_override": "the missing cosmonauts"
	},
	"dyatlov pass": {
		"text": "Mysterious deaths of hikers possibly linked to secret weapons testing or supernatural forces...",
		"image": "res://assets/textures/dyatlov.png",
		"name_override": "dyatlov pass"
	},
	"tulpas": {
		"text": "Thought forms that can manifest into physical reality through concentrated belief...",
		"image": "res://assets/textures/tulpa.png",
		"name_override": "tulpas"
	},
	"operation blue beam": {
		"text": "Plan to simulate an alien invasion using advanced holographic technology...",
		"image": "res://assets/textures/blue_beam.png",
		"name_override": "operation blue beam"
	},
	"occult knowledge": {
		"text": "Hidden magical practices and ancient wisdom kept secret by powerful organizations...",
		"image": "res://assets/textures/occult_knowledge.png",
		"name_override": "occult knowledge"
	},
	"magicka": {
		"text": "Real magical powers suppressed by modern science and skepticism...",
		"image": "res://assets/textures/magika.png",
		"name_override": "magicka"
	},
	"space is fake": {
		"text": "All space exploration is staged to hide the true nature of our universe...",
		"image": "res://assets/textures/space_is_fake.png",
		"name_override": "space is fake"
	},
	"divination": {
		"text": "Ancient methods of predicting future events through supernatural means...",
		"image": "res://assets/textures/divination.png",
		"name_override": "divination"
	},
	"pantheism": {
		"text": "Everything is connected through a universal consciousness, suppressed by organized religion...",
		"image": "res://assets/textures/pantheism.png",
		"name_override": "pantheism"
	},
	"archdemons/angels": {
		"text": "Powerful interdimensional beings influencing human affairs from hidden realms...",
		"image": "res://assets/textures/angel.png",
		"name_override": "archdemons/angels"
	},
	"philosopher's stone": {
		"text": "Ancient alchemical substance capable of transmutation and immortality...",
		"image": "res://assets/textures/alchemy.png",
		"name_override": "philosopher's stone"
	},
	"my red is not your red": {
		"text": "Reality is subjective and each person experiences a different version of consciousness...",
		"image": "res://assets/textures/red.png",
		"name_override": "my red is not your red"
	},
	"vampires": {
		"text": "Ancient bloodlines of immortal beings hiding among human society...",
		"image": "res://assets/textures/vampire_2.png",
		"name_override": "vampires"
	},
	"aura": {
		"text": "Visible energy fields surrounding all living things, hidden from most people...",
		"image": "res://assets/textures/aura.png",
		"name_override": "aura"
	},
	"bohemian grove": {
		"text": "Secret meetings of world leaders performing occult rituals...",
		"image": "res://assets/textures/owl.png",
		"name_override": "bohemian grove"
	},
	"lost civilizations": {
		"text": "Advanced ancient societies whose technology exceeded our own...",
		"image": "res://assets/textures/lost_civ.png",
		"name_override": "lost civilizations"
	},
	"paranormal beings": {
		"text": "Entities from other dimensions regularly interacting with our world...",
		"image": "res://assets/textures/paranomal_beings.png",
		"name_override": "paranormal beings"
	},
	"gangstalking": {
		"text": "Organized harassment campaigns using advanced psychological warfare techniques...",
		"image": "res://assets/textures/gangstalking.png",
		"name_override": "gangstalking"
	},
	"experiments on humans": {
		"text": "Secret government programs testing advanced technologies on unwitting citizens...",
		"image": "res://assets/textures/human_experiments.png",
		"name_override": "experiments on humans"
	},
	"6th extinction": {
		"text": "Deliberate manipulation of Earth's ecosystem to trigger mass extinction...",
		"image": "res://assets/textures/6th.png",
		"name_override": "6th extinction"
	},
	"pseudosciences": {
		"text": "Suppressed scientific discoveries that challenge mainstream understanding...",
		"image": "res://assets/textures/hand_light.png",
		"name_override": "pseudosciences"
	},
	"saturn's rings": {
		"text": "Artificial structures built by ancient alien civilizations...",
		"image": "res://assets/textures/saturn.png",
		"name_override": "saturn's rings"
	},
	"polar shift": {
		"text": "Imminent reversal of Earth's magnetic poles leading to global catastrophe...",
		"image": "res://assets/textures/earth_core.png",
		"name_override": "polar shift"
	},
	"large hadron collider": {
		"text": "Portal device designed to open gateways to other dimensions...",
		"image": "res://assets/textures/lhc.png",
		"name_override": "large hadron collider"
	},
	"oumuamua": {
		"text": "Alien probe disguised as an interstellar object...",
		"image": "res://assets/textures/ufo.png",
		"name_override": "oumuamua"
	},
	"fish rain": {
		"text": "Unexplained phenomena of aquatic life falling from the sky...",
		"image": "res://assets/textures/fish_rain.png",
		"name_override": "fish rain"
	},
	"elite politician body doubles": {
		"text": "World leaders replaced by lookalikes to maintain control...",
		"image": "res://assets/textures/clone.png",
		"name_override": "elite body doubles"
	},
	"butterfly effect": {
		"text": "Time travelers manipulating small events to change the course of history...",
		"image": "res://assets/textures/butterfly_effect.png",
		"name_override": "butterfly effect"
	},
	"ningens": {
		"text": "Humanoid sea creatures hiding in Earth's oceans...",
		"image": "res://assets/textures/ningen.png",
		"name_override": "ningens"
	},
	"oil pit squid": {
		"text": "Unknown creatures living in deep oil reservoirs...",
		"image": "res://assets/textures/squid.png",
		"name_override": "oil pit squid"
	},
	"lemuria and mount shasta": {
		"text": "Ancient civilization's survivors living within a sacred mountain...",
		"image": "res://assets/textures/shasta.png",
		"name_override": "lemuria and mount shasta"
	},
	"crystal skulls": {
		"text": "Ancient artifacts containing vast knowledge and supernatural powers...",
		"image": "res://assets/textures/skull.png",
		"name_override": "crystal skulls"
	},
	"singularity": {
		"text": "The point at which artificial intelligence surpasses human intelligence, leading to an unknowable future...",
		"image": "res://assets/textures/singularity.png",
		"name_override": "singularity"
	},
	"quantum suicide and immortality": {
		"text": "The theory that consciousness only continues in timelines where one survives, making death impossible from one's own perspective...",
		"image": "res://assets/textures/quantum.png",
		"name_override": "quantum suicide and immortality"
	},
	"pleroma": {
		"text": "The spiritual realm of divine fullness, hidden from humanity by malevolent forces...",
		"image": "res://assets/textures/pleroma.png",
		"name_override": "pleroma"
	},
	"archons": {
		"text": "Malevolent interdimensional entities that feed off human suffering and negative emotions...",
		"image": "res://assets/textures/archons.png",
		"name_override": "archons"
	},
	"sacred geometry": {
		"text": "Mathematical patterns that reveal the fundamental structure of reality and consciousness...",
		"image": "res://assets/textures/sacred_geometry.png",
		"name_override": "sacred geometry"
	},
	"DMT beings": {
		"text": "Entities encountered in altered states that may be interdimensional beings or aspects of consciousness...",
		"image": "res://assets/textures/dmt.png",
		"name_override": "DMT beings"
	},
	"thule": {
		"text": "An ancient civilization with advanced technology that influenced secret societies...",
		"image": "res://assets/textures/thule.png",
		"name_override": "thule"
	},
	"toxoplasmosis effect on the human brain": {
		"text": "A parasite that alters human behavior and may be controlling society...",
		"image": "res://assets/textures/toxo.png",
		"name_override": "toxoplasmosis"
	},
	"titanic was sunk to create the federal reserve": {
		"text": "The deliberate sinking of the Titanic to eliminate opposition to the Federal Reserve System...",
		"image": "res://assets/textures/titanic.png",
		"name_override": "titanic never sunk"
	},
	"smithsonian suppresses evidence of giants": {
		"text": "Evidence of giant human skeletons hidden to maintain conventional historical narratives...",
		"image": "res://assets/textures/giants.png",
		"name_override": "giants"
	},
	"tartaria": {
		"text": "An advanced civilization erased from history that built many of the world's grand structures...",
		"image": "res://assets/textures/tartaria2.png",
		"name_override": "tartaria"
	},
	"panspermia": {
		"text": "Life on Earth originated from elsewhere in the cosmos, possibly seeded intentionally...",
		"image": "res://assets/textures/panspermia.png",
		"name_override": "panspermia"
	},
	"grey goo": {
		"text": "Self-replicating nanobots that could consume all matter on Earth...",
		"image": "res://assets/textures/grey_goo.png",
		"name_override": "grey goo"
	},
	"fullcanelli": {
		"text": "An immortal alchemist who achieved the philosopher's stone and still walks among us...",
		"image": "res://assets/textures/fullcanelli.png",
		"name_override": "fullcanelli"
	},
	"dogon tribe": {
		"text": "An African tribe with inexplicable ancient knowledge of astronomical phenomena...",
		"image": "res://assets/textures/dogon.png",
		"name_override": "dogon tribe"
	},
	"lord pakal's time machine": {
		"text": "Ancient Mayan artwork depicting a ruler operating an advanced technological device...",
		"image": "res://assets/textures/pakal.png",
		"name_override": "lord pakal's time machine"
	},
	"pesticides and the american food supply": {
		"text": "Deliberate contamination of food to control population health and consciousness...",
			"image": "res://assets/textures/corn.png",
		"name_override": "american food supply"
	},
	"vimana": {
		"text": "Ancient Sanskrit texts describing advanced flying machines and their operation...",
		"image": "res://assets/textures/vimana.png",
		"name_override": "vimana"
	},
	"washington dc street plan designed by freen masons": {
		"text": "The capital's layout contains occult symbols and geometric patterns for ritual purposes...",
		"image": "res://assets/textures/streetplan.png",
		"name_override": "washington dc street plan"
	},
	"grand unified conspiracy theory": {
		"text": "All conspiracy theories are connected in a single, vast web of hidden truth...",
		"image": "res://assets/textures/theory.png",
		"name_override": "grand unified conspiracy theory"
	},
	"baltic sea anomaly": {
		"text": "Mysterious underwater structure possibly of extraterrestrial origin...",
		"image": "res://assets/textures/baltic_sea.png",
		"name_override": "baltic sea anomaly"
	},
	"Nimrod control system": {
		"text": "Ancient system of control still operating through modern institutions...",
		"image": "res://assets/textures/nimrod.png",
		"name_override": "Nimrod control system"
	},
	"global depopulation": {
		"text": "Coordinated efforts to reduce world population through various means...",
		"image": "res://assets/textures/tree.png",
		"name_override": "global depopulation"
	},
	"holotropic breathworks": {
		"text": "Breathing techniques that access alternate dimensions and past lives...",
		"image": "res://assets/textures/breath.png",
		"name_override": "holotropic breathworks"
	},
	"hermeticism": {
		"text": "Ancient magical and philosophical tradition containing ultimate truth...",
		"image": "res://assets/textures/hermes.png",
		"name_override": "hermeticism"
	},
	"negative-entropy": {
		"text": "Hidden technology that reverses the flow of entropy and aging...",
		"image": "res://assets/textures/negative-entropy.png",
		"name_override": "negative-entropy"
	},
	"nexus 7": {
		"text": "Secret government program studying consciousness and reality manipulation...",
		"image": "res://assets/textures/stonks.png",
		"name_override": "nexus 7"
	},
	"geometrodynamics": {
		"text": "The manipulation of space-time through geometric structures and frequencies...",
		"image": "res://assets/textures/portal.png",
		"name_override": "geometrodynamics"
	},
	"cave dweller holocaust": {
		"text": "Ancient genocide of subterranean human subspecies...",
		"image": "res://assets/textures/cdh.png",
		"name_override": "cave dweller holocaust"
	},
	"dolphin intelligence": {
		"text": "Dolphins possess advanced consciousness and knowledge suppressed by governments...",
		"image": "res://assets/textures/dolphin.png",
		"name_override": "dolphin intelligence"
	},
	"himalayan zombies (rolang)": {
		"text": "Ancient Tibetan practice of reanimating corpses through ritual magic...",
		"image": "res://assets/textures/rolang.png",
		"name_override": "himalayan zombies (rolang)"
	},
	"deep philosophies/ hermenuetics": {
		"text": "Hidden layers of meaning in reality accessible through specific interpretative methods...",
		"image": "res://assets/textures/hermenuetics.png",
		"name_override": "deep philosophies/hermenuetics"
	},
	"mirl cults": {
		"text": "Modern industrial religious logistics - corporate control through spiritual manipulation...",
		"image": "res://assets/textures/cult.png",
		"name_override": "mirl cults"
	},
	"toronto protocol": {
		"text": "Secret agreement for global social engineering and population control...",
		"image": "res://assets/textures/toronto_protocol_00001_.png",
		"name_override": "toronto protocol"
	},
	"presentism": {
		"text": "Only the present moment exists; past and future are illusions maintained by consciousness...",
		"image": "res://assets/textures/presentism.png",
		"name_override": "presentism"
	},
	"bootes void": {
		"text": "Massive empty region of space possibly housing advanced civilizations...",
		"image": "res://assets/textures/void.png",
		"name_override": "bootes void"
	},
	"plant intelligence": {
		"text": "Plants possess advanced consciousness and communicate through hidden networks...",
		"image": "res://assets/textures/plant_intelligence_00001_.png",
		"name_override": "plant intelligence"
	},
	"last thursdayism": {
		"text": "The universe was created last Thursday with false memories and evidence of age...",
		"image": "res://assets/textures/thursday.png",
		"name_override": "last thursdayism"
	},
	"acosmism": {
		"text": "The physical world is an illusion; only the spiritual realm truly exists...",
		"image": "res://assets/textures/acosmism.png",
		"name_override": "acosmism"
	},
	"abiogenic oil": {
		"text": "Oil is not fossil fuel but is continuously produced within the Earth...",
		"image": "res://assets/textures/oil.png",
		"name_override": "abiogenic oil"
	},
	"secret societies today": {
		"text": "Modern organizations controlling world events through ancient knowledge...",
		"image": "res://assets/textures/secret.png",
		"name_override": "secret societies today"
	},
	"prison planet": {
		"text": "Earth is a controlled environment designed to contain consciousness...",
		"image": "res://assets/textures/prison_planet.png",
		"name_override": "prison planet"
	},
	"malta catacombs": {
		"text": "Ancient underground structures containing evidence of advanced civilizations...",
		"image": "res://assets/textures/malta.png",
		"name_override": "malta catacombs"
	},
	"patomskiy crater": {
		"text": "Mysterious Siberian formation possibly created by advanced ancient technology...",
		"image": "res://assets/textures/patomskiy_crater_00001_.png",
		"name_override": "patomskiy crater"
	},
	"animism": {
		"text": "All objects and natural phenomena possess consciousness and intent...",
		"image": "res://assets/textures/animism.png",
		"name_override": "animism"
	},
	"montanism": {
		"text": "Ancient Christian movement suppressed for revealing too much truth...",
		"image": "res://assets/textures/montanism.png",
		"name_override": "montanism"
	},
	"operation paper clip": {
		"text": "Secret program to integrate Nazi scientists and their occult knowledge into America...",
		"image": "res://assets/textures/paperclip.png",
		"name_override": "operation paper clip"
	},
	"magic of the state": {
		"text": "Government power maintained through occult rituals and symbolic manipulation...",
		"image": "res://assets/textures/magic_of_the_state.png",
		"name_override": "magic of the state"
	},
	"sycamore knoll underwater alien base": {
		"text": "Secret underwater facility housing extraterrestrial technology and beings...",
		"image": "res://assets/textures/knoll.png",
		"name_override": "sycamore knoll"
	},
	"reactionless drive": {
		"text": "Suppressed technology enabling propulsion without expelling mass...",
		"image": "res://assets/textures/drive.png",
		"name_override": "reactionless drive"
	},
	"enneagram": {
		"text": "Ancient system of personality classification with hidden spiritual significance...",
		"image": "res://assets/textures/hypersigil.png",
		"name_override": "enneagram"
	},
	"protodite": {
		"text": "Microscopic silicon-based life forms existing alongside carbon-based life...",
		"image": "res://assets/textures/protodyte.png",
		"name_override": "protodite"
	},
	"accoustic attacks": {
		"text": "Secret weapons using sound frequencies to control minds and bodies...",
		"image": "res://assets/textures/accoustic_attack.png",
		"name_override": "accoustic attacks"
	},
	"panopticon": {
		"text": "Invisible system of total surveillance controlling human behavior...",
		"image": "res://assets/textures/panopticon.png",
		"name_override": "panopticon"
	},
	"prana release": {
		"text": "Technique to harness universal life energy for supernatural abilities...",
		"image": "res://assets/textures/prana_release_00001_.png",
		"name_override": "prana release"
	},
	"corporate kill list": {
		"text": "Secret database of individuals targeted for elimination by major corporations...",
		"image": "res://assets/textures/killlist.png",
		"name_override": "corporate kill list"
	},
	"interdimensional bigfoot": {
		"text": "Cryptids capable of moving between parallel realities to avoid detection...",
		"image": "res://assets/textures/bigfoot.png",
		"name_override": "interdimensional bigfoot"
	},
	"ghost condensate": {
		"text": "Mysterious substance that modifies gravity and enables paranormal phenomena...",
		"image": "res://assets/textures/ghost_condesate.png",
		"name_override": "ghost condensate"
	},
	"organic black helicopters": {
		"text": "Living aircraft grown from alien biological technology...",
		"image": "res://assets/textures/black_helicopter.png",
		"name_override": "organic black helicopters"
	},
	"breatharianism": {
		"text": "Secret technique to survive solely on air and light energy...",
		"image": "res://assets/textures/breathing.png",
		"name_override": "breatharianism"
	},
	"psychotropic warfare": {
		"text": "Military use of consciousness-altering frequencies and substances...",
		"image": "res://assets/textures/psychotropic.png",
		"name_override": "psychotropic warfare"
	},
	"All of human history is fake": {
		"text": "Historical records fabricated to hide the true nature of human civilization...",
		"image": "res://assets/textures/history.png",
		"name_override": "history is fake"
	},
	"object oriented ontology": {
		"text": "Philosophy revealing that consciousness exists in all objects and materials...",
		"image": "res://assets/textures/ooo.png",
		"name_override": "object oriented ontology"
	},
	"accelerationism": {
		"text": "Deliberate acceleration of technological growth to force societal collapse...",
		"image": "res://assets/textures/horse.png",
		"name_override": "accelerationism"
	},
	"omphalos": {
		"text": "Universe created with false appearance of age and pre-existing history...",
		"image": "res://assets/textures/omphalos.png",
		"name_override": "omphalos"
	},
	"quantum entanglement": {
		"text": "Instantaneous communication network used by elite groups...",
		"image": "res://assets/textures/quantum_entanglement_00001_.png",
		"name_override": "quantum entanglement"
	},
	"kundalini energy": {
		"text": "Dormant spiritual power suppressed by modern society...",
		"image": "res://assets/textures/kundalini.png",
		"name_override": "kundalini energy"
	},
	"brain in a jar": {
		"text": "Human consciousness existing in simulated reality maintained by advanced AI...",
		"image": "res://assets/textures/brain_in_jar.png",
		"name_override": "brain in a jar"
	},
	"symbiogenesis": {
		"text": "Controlled evolution through merger with artificial life forms...",
		"image": "res://assets/textures/symbio.png",
		"name_override": "symbiogenesis"
	},
	"antikythera mechanism": {
		"text": "Ancient computer revealing advanced knowledge of cosmic cycles...",
		"image": "res://assets/textures/mechanism.png",
		"name_override": "antikythera mechanism"
	},
	"anatta": {
		"text": "The self is an illusion maintained by external consciousness controllers...",
		"image": "res://assets/textures/self.png",
		"name_override": "anatta"
	},
	"polywater": {
		"text": "Artificially modified water with anomalous properties and effects on consciousness...",
		"image": "res://assets/textures/polywater.png",
		"name_override": "polywater"
	},
	"human genome projects true purpose": {
		"text": "Secret program to identify and activate dormant alien DNA in humans...",
		"image": "res://assets/textures/dna.png",
		"name_override": "human genome project"
	},
	"bogandoff twins are powerful psychic archangle superhumans who will usher in an age of genetic engineering": {
		"text": "The mysterious Bogdanoff twins possess supernatural abilities and are guiding humanity's genetic evolution...",
		"image": "res://assets/textures/bogandoff_twins_are_powerful_psychic_archangle_superhumans_who_will_usher_in_an_age_of_genetic_engineering_00001_.png",
		"name_override": "bogandoff twins"
	},
	"dead internet theory": {
		"text": "Most of the internet is generated by AI, with real human activity being a tiny fraction...",
		"image": "res://assets/textures/dead_internet.png",
		"name_override": "dead internet theory"
	},
	"quantum computers are trapped demonic entities": {
		"text": "Quantum computing works by enslaving interdimensional beings for computational power...",
		"image": "res://assets/textures/quantum_computer.png",
		"name_override": "quantum computers"
	},
	"subjective reality": {
		"text": "Individual consciousness creates its own unique reality, with shared reality being an illusion...",
		"image": "res://assets/textures/subjective.png",
		"name_override": "subjective reality"
	},
	"spiritual microeconomy": {
		"text": "Hidden economic system based on trading spiritual energy and karmic debt...",
		"image": "res://assets/textures/spiritual_micro.png",
		"name_override": "spiritual microeconomy"
	},
	"the american government fought the iraq war to secure the tomb of gilgamesh": {
		"text": "Military operations in Iraq were cover for securing ancient supernatural artifacts...",
		"image": "res://assets/textures/gilgamesh.png",
		"name_override": "tomb ofgilgamesh"
	},
	"synchronicity": {
		"text": "Meaningful coincidences are actually glimpses of the universe's true interconnected nature...",
		"image": "res://assets/textures/synchronicity.png",
		"name_override": "synchronicity"
	},
	"dream hacking": {
		"text": "Technology exists to infiltrate and manipulate dreams for mind control...",
		"image": "res://assets/textures/dream_hacking.png",
		"name_override": "dream hacking"
	},
	"S EN": {
		"text": "Secret energy network powering advanced civilizations through dimensional tapping...",
		"image": "res://assets/textures/s_en.png",
		"name_override": "s en"
	},
	"captivity suburbs": {
		"text": "Suburban developments designed as psychological containment zones...",
		"image": "res://assets/textures/burbs.png",
		"name_override": "captivity suburbs"
	},
	"kali yuga describes an inevitable cycle of moral decay and corruption leading to heroic destruction and a restoriation of morality that all societies eventually go through": {
		"text": "Ancient Hindu prophecy accurately predicting current global societal collapse...",
		"image": "res://assets/textures/kali.png",
		"name_override": "kali yuga"
	},
	"torsion fields": {
		"text": "Undiscovered force field that affects consciousness and physical reality...",
		"image": "res://assets/textures/torsion.png",
		"name_override": "torsion fields"
	},
	"morphic field": {
		"text": "Invisible field that stores and transmits collective memories and behaviors...",
		"image": "res://assets/textures/morphic.png",
		"name_override": "morphic field"
	},
	"genepool financialization": {
		"text": "Secret market trading future human genetic potential as commodity...",
		"image": "res://assets/textures/genepool_financialization_00001_.png",
		"name_override": "genepool financialization"
	},
	"The universe is a hologram": {
		"text": "Reality is a projection from a two-dimensional boundary of space...",
		"image": "res://assets/textures/holographic.png",
		"name_override": "The universe is a hologram"
	},
	"hypersigils": {
		"text": "Magical symbols embedded in media that can alter reality through mass consciousness...",
		"image": "res://assets/textures/hypersigil2.png",
		"name_override": "hypersigils"
	},
	"amazon rainforrest was built by an ancient society": {
		"text": "The Amazon rainforest is actually a carefully designed agricultural system from an advanced civilization...",
		"image": "res://assets/textures/amazon_rainforrest_was_built_by_an_ancient_society_00001_.png",
		"name_override": "amazon rainforrest"
	},
	"akashic records": {
		"text": "A cosmic database containing all knowledge and experiences from all times...",
		"image": "res://assets/textures/akashik.png",
		"name_override": "akashic records"
	},
	"classical metaphysics": {
		"text": "Ancient understanding of reality suppressed by modern materialistic science...",
		"image": "res://assets/textures/classical.png",
		"name_override": "classical metaphysics"
	},
	"annunaki created humans to mine gold": {
		"text": "Ancient alien beings engineered humanity as a slave race for gold extraction...",
		"image": "res://assets/textures/gold.png",
		"name_override": "annunaki"
	},
	"soy products are weaponized aginst the public to make them have less testosterone and therefore more agreeable to government control": {
		"text": "Deliberate chemical manipulation of population through food supply...",
		"image": "res://assets/textures/soy.png",
		"name_override": "weaponized soy"
	},
	"bicameralism of the human brain, ancient people could hear the voices of gods": {
		"text": "Ancient humans had different consciousness structure allowing direct divine communication...",
		"image": "res://assets/textures/bicameralism.png",
		"name_override": "bicameralism"
	},
	"The true purpose of the great pyramind": {
		"text": "Ancient power plant or interdimensional communication device hidden in plain sight...",
		"image": "res://assets/textures/pyramid.png",
		"name_override": "pyramind's true purpose"
	},
	"moon built by aliens": {
		"text": "The moon is an artificial satellite constructed by advanced extraterrestrial civilization...",
		"image": "res://assets/textures/moon.png",
		"name_override": "moon built by aliens"
	},
	"field conciousness": {
		"text": "All consciousness is connected through an invisible field manipulated by powerful entities...",
		"image": "res://assets/textures/field_conciousness.png",
		"name_override": "field conciousness"
	},
	"humanity shares a flood myth": {
		"text": "Global flood stories indicate suppressed historical truth about ancient catastrophe...",
		"image": "res://assets/textures/tidal_wave.png",
		"name_override": "shared flood myth"
	},
	"non-space": {
		"text": "The void between celestial bodies is actually filled with an unknown substance or medium...",
		"image": "res://assets/textures/nonspace.png",
		"name_override": "non-space"
	},
	"timecube": {
		"text": "Time is cubic and education suppresses this fundamental truth about reality...",
		"image": "res://assets/textures/timecube.png",
		"name_override": "timecube"
	},
	"wetiko": {
		"text": "A mind virus that causes humans to consume life force and spread destructive behavior...",
		"image": "res://assets/textures/wetiko.png",
		"name_override": "wetiko"
	},
	"the nephelim looked like clowns": {
		"text": "Ancient hybrid beings manifested as what we now recognize as clown archetypes...",
		"image": "res://assets/textures/clownish.png",
		"name_override": "the nephelim"
	},
	"deep soy, xeno estrogens": {
		"text": "Hidden chemical compounds in modern food designed to alter human biology...",
		"image": "res://assets/textures/xeno.png",
		"name_override": "deep soy, xeno estrogens"
	},
	"eating food makes you age": {
		"text": "The digestive process accelerates cellular degradation and mortality...",
		"image": "res://assets/textures/eating.png",
		"name_override": "eating food makes you age"
	},
	"wars are started on purpose for the sake of profit": {
		"text": "Global conflicts engineered by shadow organizations for financial gain...",
		"image": "res://assets/textures/profit.png",
		"name_override": "wars for profit"
	},
	"microchips found in fossils": {
		"text": "Evidence of advanced ancient technology discovered in prehistoric remains...",
		"image": "res://assets/textures/fossil.png",
		"name_override": "microchips found in fossils"
	},
	"retrocausality": {
		"text": "Future events can influence the past through quantum entanglement across time...",
		"image": "res://assets/textures/retro.png",
		"name_override": "retrocausality"
	},
	"ancient egypt was advanced and the sphinx was eroded by water ina great flood": {
		"text": "Evidence of advanced ancient Egyptian civilization and catastrophic flooding hidden from public...",
		"image": "res://assets/textures/floodingegypt.png",
		"name_override": "khemet"
	},
	"phlogiston theory resurfacing": {
		"text": "Suppressed scientific theory about the true nature of energy and matter...",
		"image": "res://assets/textures/phlogiston.png",
		"name_override": "phlogiston theory resurfacing"
	},
	"nano-ufos and giga-ufos": {
		"text": "Extraterrestrial craft operating at microscopic and massive scales simultaneously...",
		"image": "res://assets/textures/nanoufo.png",
		"name_override": "nano-ufos and giga-ufos"
	},
	"regenerative death consumption": {
		"text": "Secret technique to absorb life force from the moment of death for immortality...",
		"image": "res://assets/textures/rdc.png",
		"name_override": "regenerative death consumption"
	},
	"thoth was an alchemist and a high preist in ancient atlantis": {
		"text": "Egyptian god was actually an advanced being from Atlantis teaching sacred knowledge...",
		"image": "res://assets/textures/thoth.png",
		"name_override": "thoth"
	},
	"secret human potential": {
		"text": "Humans possess dormant supernatural abilities suppressed by modern society...",
		"image": "res://assets/textures/potential.png",
		"name_override": "secret human potential"
	},
	"gods last wish was for humans to have free will": {
		"text": "The divine plan culminates in complete human autonomy from all higher powers...",
		"image": "res://assets/textures/monad.png",
		"name_override": "gods last wish"
	},
	"oikeiosis": {
		"text": "The process of cosmic self-realization leading to ultimate understanding of one's place in reality...",
		"image": "res://assets/textures/oikeiosis.png",
		"name_override": "oikeiosis"
	},
	"all conspiracies are true": {
		"text": "Every conspiracy theory contains elements of truth in some parallel reality or dimension...",
		"image": "res://assets/textures/true.png",
		"name_override": "all conspiracies are true"
	},
	"fractialization": {
		"text": "Reality continuously splits into infinite variations, each containing different versions of truth...",
		"image": "res://assets/textures/fractal.png",
		"name_override": "fractialization"
	},
	"god's ego death": {
		"text": "The universe is experiencing the dissolution of divine consciousness into infinite awareness...",
		"image": "res://assets/textures/egodeath.png",
		"name_override": "god's ego death"
	},
	"There is no conspiracy": {
		"text": "The ultimate realization that chaos and randomness govern all events, making conspiracy impossible...",
		"image": "res://assets/textures/no_conspiracy.png",
		"name_override": "there is no conspiracy"
	},
	"The final understanding": {
		"text": "The paradoxical truth that complete knowledge reveals the impossibility of absolute truth...",
		"image": "res://assets/textures/final.png",
		"name_override": "the final understanding"
	}
}

func _ready():
	setup_ui()
	seed(SPACING_SEED)
	generate_buttons()

func _process(_delta):
	if memo_panel and memo_panel.visible:
		# Keep the memo panel centered in the viewport
		var viewport_size = get_viewport_rect().size
		memo_panel.global_position = (viewport_size - MEMO_PANEL_SIZE) / 2

func setup_ui():
	# Create ButtonContainer
	button_container = Control.new()
	button_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(button_container)
	
	# Create MemoPanel
	memo_panel = Panel.new()
	memo_panel.visible = false
	memo_panel.custom_minimum_size = MEMO_PANEL_SIZE
	memo_panel.size = MEMO_PANEL_SIZE
	
	# Set up the panel to be centered
	memo_panel.set_anchors_preset(Control.PRESET_CENTER)
	memo_panel.position = -MEMO_PANEL_SIZE / 2
	add_child(memo_panel)
	
	# Create MarginContainer
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 20)
	margin_container.add_theme_constant_override("margin_right", 20)
	margin_container.add_theme_constant_override("margin_top", 20)
	margin_container.add_theme_constant_override("margin_bottom", 20)
	memo_panel.add_child(margin_container)
	
	# Create VBoxContainer
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin_container.add_child(vbox)
	
	# Create Title Label
	memo_title = Label.new()
	memo_title.name = "MemoTitle"
	memo_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	memo_title.add_theme_font_override("font", custom_font)
	memo_title.add_theme_font_size_override("font_size", 36)
	memo_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	memo_title.custom_minimum_size = Vector2(0, 50)
	memo_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(memo_title)
	print("Created memo title node with name: ", memo_title.name)
	
	# Create MemoImage
	memo_image = TextureRect.new()
	memo_image.custom_minimum_size = Vector2(0, 200)
	memo_image.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	memo_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(memo_image)
	
	# Create ScrollContainer for text
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.custom_minimum_size = Vector2(0, 200)
	vbox.add_child(scroll_container)
	
	# Create VBoxContainer for text centering
	var text_container = VBoxContainer.new()
	text_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(text_container)
	
	# Create MemoText
	memo_text = RichTextLabel.new()
	memo_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	memo_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	memo_text.add_theme_font_override("normal_font", custom_font)
	memo_text.add_theme_font_size_override("normal_font_size", 24)
	memo_text.bbcode_enabled = true
	memo_text.text = "Memo text goes here..."
	memo_text.fit_content = true
	memo_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_container.add_child(memo_text)
	
	# Create BackButton
	back_button = Button.new()
	back_button.custom_minimum_size = Vector2(200, 50)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.add_theme_font_override("font", custom_font)
	back_button.add_theme_font_size_override("font_size", 30)
	back_button.text = "BACK"
	back_button.pressed.connect(_on_back_button_pressed)
	vbox.add_child(back_button)

func update_tier_2_vertical_offset(new_offset):
	tier_2_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 2:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_2_vertical_offset

func update_vertical_offset(new_offset):
	tier_1_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 1:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_1_vertical_offset

func update_tier_3_vertical_offset(new_offset):
	tier_3_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 3:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_3_vertical_offset

func update_tier_4_vertical_offset(new_offset):
	tier_4_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 4:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_4_vertical_offset

func update_tier_5_vertical_offset(new_offset):
	tier_5_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 5:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_5_vertical_offset

func update_tier_6_vertical_offset(new_offset):
	tier_6_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 6:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_6_vertical_offset

func update_tier_7_vertical_offset(new_offset):
	tier_7_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 7:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_7_vertical_offset

func update_tier_8_vertical_offset(new_offset):
	tier_8_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 8:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_8_vertical_offset

func update_tier_9_vertical_offset(new_offset):
	tier_9_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 9:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_9_vertical_offset

func update_tier_10_vertical_offset(new_offset):
	tier_10_vertical_offset = new_offset
	if not button_container:
		return
	for button in button_container.get_children():
		if button.has_meta("tier") and button.get_meta("tier") == 10:
			var base_pos = button.get_meta("base_position")
			button.position.y = base_pos.y + tier_10_vertical_offset

func create_button(key: String, tier_number: int, viewport_size: Vector2, screen_margin: float, start_y: float, tiers: Dictionary, current_tier: int, rng: RandomNumberGenerator) -> void:
	var button_instance = conspiracy_menu_button.instantiate()
	button_container.add_child(button_instance)
	button_instance.show_memo.connect(_on_button_show_memo)
	
	# Update the button with its key
	if button_instance.has_method("update_button_by_key"):
		button_instance.update_button_by_key(key)
		button_instance.override_name(memo_content[key].name_override)
		button_instance.set_description(memo_content[key].text)
		button_instance.override_image(memo_content[key].image)
	
	# Scale the button
	button_instance.scale = Vector2(button_scale, button_scale)
	var button_width = button_instance.size.x * button_scale
	
	# Initialize tier if not exists
	if not tiers.has(current_tier):
		tiers[current_tier] = []
	
	# Try to find a valid position in current tier
	var position_found = false
	var max_attempts = 10  # Prevent infinite loops
	var attempts = 0
	
	while not position_found and attempts < max_attempts:
		# Generate a potential x position
		var center_x = (viewport_size.x - button_width) / 2
		var max_offset = viewport_size.x * max_horizontal_ratio
		var h_offset = rng.randf_range(-max_offset, max_offset)
		var x_pos = clamp(center_x + h_offset, screen_margin, viewport_size.x - button_width - screen_margin)
		
		# Check if this position overlaps with any existing buttons in this tier
		var overlaps = false
		for existing_button in tiers[current_tier]:
			if abs(existing_button.x - x_pos) < (button_width + MIN_BUTTON_SPACING):
				overlaps = true
				break
		
		if not overlaps:
			position_found = true
			var y_pos = start_y + (current_tier * tier_height)
			var base_position = Vector2(x_pos, y_pos)
			button_instance.set_meta("base_position", base_position)
			button_instance.set_meta("tier", tier_number)
			
			# Apply the appropriate vertical offset based on the tier
			var vertical_offset: float
			if tier_number == 1:
				vertical_offset = tier_1_vertical_offset
			elif tier_number == 2:
				vertical_offset = tier_2_vertical_offset
			elif tier_number == 3:
				vertical_offset = tier_3_vertical_offset
			elif tier_number == 4:
				vertical_offset = tier_4_vertical_offset
			elif tier_number == 5:
				vertical_offset = tier_5_vertical_offset
			elif tier_number == 6:
				vertical_offset = tier_6_vertical_offset
			elif tier_number == 7:
				vertical_offset = tier_7_vertical_offset
			elif tier_number == 8:
				vertical_offset = tier_8_vertical_offset
			elif tier_number == 9:
				vertical_offset = tier_9_vertical_offset
			else:
				vertical_offset = tier_10_vertical_offset
			button_instance.position = Vector2(x_pos, y_pos + vertical_offset)
			tiers[current_tier].append(Vector2(x_pos, y_pos))
		
		attempts += 1
		
		# If we couldn't find a spot after several attempts, move to next tier
		if attempts >= max_attempts:
			current_tier += 1
			if not tiers.has(current_tier):
				tiers[current_tier] = []
			attempts = 0  # Reset attempts for new tier
	
	# If current tier is full, move to next tier
	if tiers[current_tier].size() >= buttons_per_tier:
		current_tier += 1

func generate_buttons():
	var viewport_size = get_viewport_rect().size
	var screen_margin = viewport_size.x * SCREEN_MARGIN_RATIO
	var base_start_y = screen_margin
	
	# Create a new random number generator with our seed
	var rng = RandomNumberGenerator.new()
	rng.seed = SPACING_SEED
	
	# Create a structure to track button positions in each tier
	var tiers = {}
	var current_tier = 0
	
	print("Generating tier 1 buttons...")
	# Generate tier 1 buttons
	var tier1_start_y = base_start_y
	for key in tier_1_keys:
		create_button(key, 1, viewport_size, screen_margin, tier1_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 2 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 2 buttons...")
	# Generate tier 2 buttons
	var tier2_start_y = base_start_y + viewport_size.y * 0.10  # 10% down the screen
	for key in tier_2_keys:
		create_button(key, 2, viewport_size, screen_margin, tier2_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 3 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 3 buttons...")
	# Generate tier 3 buttons
	var tier3_start_y = base_start_y + viewport_size.y * 0.20  # 20% down the screen
	for key in tier_3_keys:
		create_button(key, 3, viewport_size, screen_margin, tier3_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 4 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 4 buttons...")
	# Generate tier 4 buttons
	var tier4_start_y = base_start_y + viewport_size.y * 0.30  # 30% down the screen
	for key in tier_4_keys:
		create_button(key, 4, viewport_size, screen_margin, tier4_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 5 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 5 buttons...")
	# Generate tier 5 buttons
	var tier5_start_y = base_start_y + viewport_size.y * 0.40  # 40% down the screen
	for key in tier_5_keys:
		create_button(key, 5, viewport_size, screen_margin, tier5_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 6 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 6 buttons...")
	# Generate tier 6 buttons
	var tier6_start_y = base_start_y + viewport_size.y * 0.50  # 50% down the screen
	for key in tier_6_keys:
		create_button(key, 6, viewport_size, screen_margin, tier6_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 7 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 7 buttons...")
	# Generate tier 7 buttons
	var tier7_start_y = base_start_y + viewport_size.y * 0.60  # 60% down the screen
	for key in tier_7_keys:
		create_button(key, 7, viewport_size, screen_margin, tier7_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 8 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 8 buttons...")
	# Generate tier 8 buttons
	var tier8_start_y = base_start_y + viewport_size.y * 0.70  # 70% down the screen
	for key in tier_8_keys:
		create_button(key, 8, viewport_size, screen_margin, tier8_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 9 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 9 buttons...")
	# Generate tier 9 buttons
	var tier9_start_y = base_start_y + viewport_size.y * 0.80  # 80% down the screen
	for key in tier_9_keys:
		create_button(key, 9, viewport_size, screen_margin, tier9_start_y, tiers, current_tier, rng)
	
	# Reset current_tier for tier 10 buttons
	current_tier = 0
	tiers.clear()
	
	print("Generating tier 10 buttons...")
	# Generate tier 10 buttons
	var tier10_start_y = base_start_y + viewport_size.y * 0.90  # 90% down the screen
	for key in tier_10_keys:
		create_button(key, 10, viewport_size, screen_margin, tier10_start_y, tiers, current_tier, rng)
	
	print("Button generation complete")

func _on_button_show_memo(key: String):
	if memo_content.has(key):
		var content = memo_content[key]
		memo_text.text = key.to_upper().replace(' ', '_')
		memo_image.texture = load(content.image)
		memo_title.text = content.name_override
		print("Set memo title text to: ", memo_title.text)
		button_container.hide()
		memo_panel.show()
		emit_signal("memo_toggled", true)

func _on_back_button_pressed():
	memo_panel.hide()
	button_container.show()
	emit_signal("memo_toggled", false)

func set_ui_offset(offset):
	current_ui_offset = offset
	position.y = offset
