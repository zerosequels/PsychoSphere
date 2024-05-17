extends Sprite3D

@onready var bar = $SubViewport/Panel/TextureProgressBar

func _initialize_health_bar(max_health:float):
	bar.max_value = max_health
	bar.value = max_health
	
func set_value(new_value:float):
	bar.value = new_value
	
