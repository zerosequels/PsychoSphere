extends Control

@onready var hand_box = $CanvasLayer/hand_box
@onready var card_prefab = preload("res://scenes/card_setup.tscn")
@onready var pyramid_card = preload("res://scenes/pyramid_card.tscn")
@onready var ankh_card = preload("res://scenes/ankh_card.tscn")
@onready var third_eye_card = preload("res://scenes/third_eye_card.tscn")
@onready var spiral_card = preload("res://scenes/spiral_card.tscn")
@onready var fol_card = preload("res://scenes/fol_card.tscn")
@onready var emerald_tablet_card = preload("res://scenes/emerald_tablet_card.tscn")
@onready var mani_wheel_card = preload("res://scenes/mani_wheel_card.tscn")
@onready var timecube_card = preload("res://scenes/timecube_card.tscn")
@onready var fork_card = preload("res://scenes/fork_card.tscn")
@onready var fungus_card = preload("res://scenes/fungus_card.tscn")
@onready var magnum_opus_card = preload("res://scenes/magnum_opus_card.tscn")
@onready var cosmic_egg_card = preload("res://scenes/cosmic_egg_card.tscn")
@onready var annunaki_card = preload("res://scenes/annunaki_card.tscn")
@onready var hand_layer = $CanvasLayer
var max_hand_size:int = 13

var hand_array = []

signal tower_toggled(tower_type_enum:int,tower_price:int)
signal price_update(tower_type_enum:int,tower_price:int)
signal _is_card_hovered(is_hovered:bool)

func toggle_hide_hand(toggle):
	if toggle:
		hand_layer.visible = false
	else:
		hand_layer.visible = true

func add_card_by_type(type:int):
	type = clampi(type,0,12)
	var name = TowerAndBoonData.get_tower_name(type)
	var price = TowerAndBoonData.get_next_tower_price_and_increment_count(type)
	add_card(name,price,type)

func add_card(card_name:String, card_price:int, card_type:int):
	var new_card
	match card_type:
		0:
			new_card = pyramid_card.instantiate()
		1:
			new_card = third_eye_card.instantiate()
		2:
			new_card = ankh_card.instantiate()
		3:
			new_card = spiral_card.instantiate()
		4:
			new_card = fol_card.instantiate()
		5:
			new_card = emerald_tablet_card.instantiate()
		6:
			new_card = mani_wheel_card.instantiate()
		7:
			new_card = timecube_card.instantiate()
		8:
			new_card = fork_card.instantiate()
		9:
			new_card = fungus_card.instantiate()
		10:
			new_card = magnum_opus_card.instantiate()
		11:
			new_card = cosmic_egg_card.instantiate()
		12:
			new_card = annunaki_card.instantiate()
		_:
			new_card = card_prefab.instantiate()


	hand_box.add_child(new_card)
	new_card.set_tower_name(card_name)
	new_card.set_price(card_price)
	new_card.set_tower_type(card_type)
	new_card.card_selected.connect(_on_card_selected)
	new_card.price_updated.connect(_on_price_updated)
	new_card.is_card_hovered.connect(_on_card_hovered)
	hand_array.append(new_card)

func _on_card_hovered(is_hovered:bool):
	emit_signal("_is_card_hovered",is_hovered)

func _on_price_updated(type:int, price:int):
	emit_signal("price_update",type,price)

func _on_card_selected(tower_type_enum:int,tower_price:int):
	emit_signal("tower_toggled",tower_type_enum,tower_price)
	for card in hand_array:
		if card.get_tower_type() != tower_type_enum:
			card.set_is_selected(false)

func increment_cost_by_tower_type(tower_type_enum:int):
	for card in hand_array:
		if card.get_tower_type() == tower_type_enum:
			card.increment_tower_price(tower_type_enum)

func _ready():
	add_card_by_type(0)





