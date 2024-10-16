extends Area3D

signal delta_emerald_tablet_buff(delta)

func increment_emerald_tablet_buff():
	emit_signal("delta_emerald_tablet_buff",1)

func deincrement_emerald_tablet_buff():
	emit_signal("delta_emerald_tablet_buff",-1)
