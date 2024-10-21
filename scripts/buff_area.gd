extends Area3D

signal delta_emerald_tablet_buff(delta)
signal delta_spiral_buff(delta)
signal delta_flower_of_life_buff(delta)
signal delta_tuning_buff(delta)

func increment_emerald_tablet_buff():
	#print("increment_emerald_tablet_buff")
	emit_signal("delta_emerald_tablet_buff",1)

func deincrement_emerald_tablet_buff():
	#print("deincrement_emerald_tablet_buff")
	emit_signal("delta_emerald_tablet_buff",-1)

func increment_spiral_buff():
	#print("increment_spiral_buff")
	emit_signal("delta_spiral_buff",1)

func deincrement_spiral_buff():
	#print("deincrement_spiral_buff")
	emit_signal("delta_spiral_buff",-1)

func increment_flower_of_life_buff():
	#print("increment_flower_of_life_buff")
	emit_signal("delta_flower_of_life_buff",1)

func deincrement_flower_of_life_buff():
	#print("deincrement_flower_of_life_buff")
	emit_signal("delta_flower_of_life_buff",-1)

func increment_tunning_fork_buff():
	#print("increment_tuning_buff")
	emit_signal("delta_tuning_buff",1)

func deincrement_tunning_fork_buff():
	#print("deincrement_tuning_buff")
	emit_signal("delta_tuning_buff",-1)


