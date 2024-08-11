extends Node

class_name EnemySpawnData

var time_to_spawn_ms = 1000
var speed = 1
var damage_on_hit = 1
var exp_on_kill = 1
var health = 1
var enemy_size_scale:float = 1

var primary_color:Color
var highlight_color:Color

var height_offset:float

func set_health(_health:float):
	health = _health
	
func set_speed(_speed:float):
	speed = _speed

func set_exp(_exp:float):
	exp_on_kill = _exp

func set_damage(_damage:float):
	damage_on_hit = _damage

func set_spawn_time(_spawn_time:int):
	time_to_spawn_ms = _spawn_time

func set_enemy_size_scale(_size_scale:float):
	enemy_size_scale = _size_scale

func set_primary_color(color:Color):
	primary_color = color

func set_highlight_color(color:Color):
	highlight_color = color

func set_height_offset(offset:float):
	height_offset = offset
	
