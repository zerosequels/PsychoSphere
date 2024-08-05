extends Sprite3D

@onready var glowing_ticker = $SubViewport/HBoxContainer/glow_counter
@onready var cubic_ticker = $SubViewport/HBoxContainer/cubic_counter
@onready var slow_ticker = $SubViewport/HBoxContainer/slow_counter
@onready var magnum_opus_ticker = $SubViewport/HBoxContainer/magnum_opus_counter
var glowing_counter = 0
var cubic_counter = 0
var slow_counter = 0
var magnum_opus_counter = 0

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

func increment_slow(delta:int):
	slow_counter += delta
	if slow_counter < 0:
		slow_counter = 0
	if slow_counter >= 1:
		slow_counter = 1
	if slow_counter > 0:
		slow_ticker.set_visibility(true)
	elif slow_counter == 0:
		slow_ticker.set_visibility(false)

func increment_magnum_opus(delta:int):
	magnum_opus_counter += delta
	if magnum_opus_counter < 0:
		magnum_opus_counter = 0
	magnum_opus_ticker.set_counter_value(str(magnum_opus_counter))
	if magnum_opus_counter > 0:
		magnum_opus_ticker.set_visibility(true)
	elif magnum_opus_counter == 0:
		magnum_opus_ticker.set_visibility(false)

func get_glowing_count():
	return glowing_counter

func get_cubic_count():
	return cubic_counter

func get_magnum_opus_count():
	return magnum_opus_counter
