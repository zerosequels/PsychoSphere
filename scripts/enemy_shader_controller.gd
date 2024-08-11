extends Node3D

@onready var single_eyes:MeshInstance3D = $Armature/Skeleton3D/double_eyes
@onready var double_eyes:MeshInstance3D = $Armature/Skeleton3D/double_eyes_001
@onready var body:MeshInstance3D = $Armature/Skeleton3D/Sphere
@onready var mouth:MeshInstance3D = $Armature/Skeleton3D/Sphere_001

func _ready():
	remove_damage_flash(body)
	remove_damage_flash(mouth)
	remove_damage_flash(single_eyes)
	remove_damage_flash(double_eyes)

func set_enemy_primary_color(line_color:Color):
	set_mesh_color(body,line_color)

func set_enemy_highlight_color(line_color:Color):
	set_mesh_color(mouth,line_color)
	set_eye_color(line_color)

func set_eye_color(line_color:Color):
	set_mesh_color(single_eyes,line_color)
	set_mesh_color(double_eyes,line_color)
	single_eyes.get_surface_override_material(0)


func set_mesh_color(mat:MeshInstance3D, line_color:Color):
	mat.set_instance_shader_parameter("line_color",line_color)

func set_damage_flash(mat:MeshInstance3D):
	#mat.set_shader_parameter("mix_color",0.7)
	mat.set_instance_shader_parameter("mix_color",0.7)

func remove_damage_flash(mat:MeshInstance3D):
	#mat.set_shader_parameter("mix_color",0.0)
	mat.set_instance_shader_parameter("mix_color",0.0)
func damage_flash():
	if $damage_timer.is_stopped():
		set_damage_flash(body)
		set_damage_flash(mouth)
		set_damage_flash(single_eyes)
		set_damage_flash(double_eyes)
		$damage_timer.start(0)


func _on_damage_timer_timeout():
	remove_damage_flash(body)
	remove_damage_flash(mouth)
	remove_damage_flash(single_eyes)
	remove_damage_flash(double_eyes)
	$damage_timer.stop()
