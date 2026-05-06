class_name ShockWave extends TextureRect


func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	
func play_shockwave(entity):
	var mat = material as ShaderMaterial
	var center = entity.position / size
	mat.set_shader_parameter("center",center)
	$AnimationPlayer.play("shockwave")
	await $AnimationPlayer.animation_finished 
	queue_free()
	
