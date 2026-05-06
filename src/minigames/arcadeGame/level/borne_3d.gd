extends Node3D

@export var texture:Texture
@export var fond_texture:Texture
@onready var light:SpotLight3D =$FlickeringLight
func _ready():
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	$Ecran.material_override = material

func start_flicker():
	var tween = create_tween().set_loops()

	tween.tween_callback(_randomize_energy)
	tween.tween_property(light, "light_energy", light.light_energy, 0.8)
	tween.tween_interval(0.5)

func _randomize_energy():
	light.light_energy = randf_range(0.5, 1.3)
