extends Node3D

@onready var expand_path_trigger_prefab = preload("res://scenes/expand_path_button.tscn")
@onready var pyramid_tower_prefab = preload("res://scenes/tower_pyramid.tscn")
@onready var ankh_tower_prefab = preload("res://scenes/tower_ankh.tscn")
@onready var annunaki_tower_prefab = preload("res://scenes/tower_annunaki.tscn")
@onready var cosmic_egg_tower_prefab = preload("res://scenes/tower_cosmic_egg.tscn")
@onready var death_fungus_tower_prefab = preload("res://scenes/tower_death_fungus.tscn")
@onready var emerald_tablet_tower_prefab = preload("res://scenes/tower_emerald_tablet.tscn")
@onready var fol_tower_prefab = preload("res://scenes/tower_flower_of_life.tscn")
@onready var magnum_opus_tower_prefab = preload("res://scenes/tower_magnum_opus.tscn")
@onready var mani_wheel_tower_prefab = preload("res://scenes/tower_mani_wheel.tscn")
@onready var spiral_tower_prefab = preload("res://scenes/tower_spiral.tscn")
@onready var third_eye_tower_prefab = preload("res://scenes/tower_third_eye.tscn")
@onready var time_cube_tower_prefab = preload("res://scenes/tower_time_cube.tscn")
@onready var tuning_fork_tower_prefab = preload("res://scenes/tower_tuning_fork.tscn")
@onready var enemy_energy_portal = preload("res://scenes/portal_vfx.tscn")

func get_current_tower_instance():
	match TowerAndBoonData.get_currently_selected_tower():
		0:
			return pyramid_tower_prefab.instantiate()
		1:
			return third_eye_tower_prefab.instantiate()
		2:
			return ankh_tower_prefab.instantiate()
		3:
			return spiral_tower_prefab.instantiate()
		4:
			return fol_tower_prefab.instantiate()
		5:
			return emerald_tablet_tower_prefab.instantiate()
		6:
			return mani_wheel_tower_prefab.instantiate()
		7:
			return time_cube_tower_prefab.instantiate()
		8:
			return tuning_fork_tower_prefab.instantiate()
		9:
			return death_fungus_tower_prefab.instantiate()
		10:
			return magnum_opus_tower_prefab.instantiate()
		11:
			return cosmic_egg_tower_prefab.instantiate()
		12:
			return annunaki_tower_prefab.instantiate()
		_:
			print("ERROR: Tower not currently supported")
			return
