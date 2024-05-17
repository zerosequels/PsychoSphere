extends Node

class_name EnemySpawnData

var time_to_spawn_ms = 1000
var speed = 1
var damage_on_hit = 1
var exp_on_kill = 1
var health = 1

func _init(_health:float,_speed:float,_exp:float,_damage:float,_spawn_time:int):
	time_to_spawn_ms = _spawn_time
	speed = _speed
	damage_on_hit = _damage
	exp_on_kill = _exp
	health = _health
