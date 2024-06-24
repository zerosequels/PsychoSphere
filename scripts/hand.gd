extends Control

@onready var hand_box = $CanvasLayer/hand_box
@onready var card_prefab = preload("res://scenes/card_setup.tscn")

var max_hand_size:int = 13

var hand_array = []

signal tower_toggled(tower_type_enum:int,tower_price:int)
signal price_update(tower_type_enum:int,tower_price:int)

func add_card_by_type(type:int):
	type = clampi(type,0,12)
	var name = TowerAndBoonData.get_tower_name(type)
	var price = TowerAndBoonData.get_next_tower_price_and_increment_count(type)
	add_card(name,price,type)
func add_card(card_name:String, card_price:int, card_type:int):
	var new_card = card_prefab.instantiate()
	hand_box.add_child(new_card)
	new_card.set_tower_name(card_name)
	new_card.set_price(card_price)
	new_card.set_tower_type(card_type)
	new_card.card_selected.connect(_on_card_selected)
	new_card.price_updated.connect(_on_price_updated)
	hand_array.append(new_card)

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
	add_card_by_type(1)
	add_card_by_type(2)
	add_card_by_type(3)
	add_card_by_type(4)
	add_card_by_type(5)
	add_card_by_type(6)
	add_card_by_type(7)
	add_card_by_type(8)
	add_card_by_type(9)
	add_card_by_type(10)
	add_card_by_type(11)
	add_card_by_type(12)


