extends Sprite3D

@onready var glowing_ticker = $SubViewport/HBoxContainer/glow_counter
@onready var cubic_ticker = $SubViewport/HBoxContainer/cubic_counter
var glowing_counter = 0
var cubic_counter = 0

func increment_glowing(delta:int):
	glowing_counter += delta
	if glowing_counter < 0:
		glowing_counter = 0
	glowing_ticker.set_counter_value(str(glowing_counter))
	if glowing_counter > 0:
		glowing_ticker.set_visibility(true)
	elif glowing_counter == 0:
		glowing_ticker.set_visibility(false)

func increment_cubic(delta:int):
	cubic_counter += delta
	if cubic_counter < 0:
		cubic_counter = 0
	if cubic_counter >= 1:
		cubic_counter = 1
	if cubic_counter > 0:
		cubic_ticker.set_visibility(true)
	elif cubic_counter == 0:
		cubic_ticker.set_visibility(false)

func get_glowing_count():
	return glowing_counter
