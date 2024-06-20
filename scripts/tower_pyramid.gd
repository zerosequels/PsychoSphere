extends Node3D


@onready var attack_area = $turret_base/attack_area

@onready var projectile = preload("res://scenes/projectile.tscn")

var enemies_in_range = []

func _ready():
	attack_area.target_new_enemy.connect($turret_base.set_current_enemy)

func _process(delta):
	pass

func update_range(new_range:float):
	attack_area.update_range(new_range)
	
func hover_by_raycast():
	attack_area.update_last_hovered()




