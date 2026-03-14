extends ColorRect

@export var shader_properties:Dictionary[String, Array]

var eow_meter:float = 0:
	set(new_val):
		eow_meter = new_val
		update_eow()

func update_eow():
	if (material as ShaderMaterial) and (material.shader):
		var shader:Shader = material.shader
		for shader_property in shader_properties.keys():
			if shader_properties[shader_property].size() != 2: 
				printerr("Currently only supports interpolation between two values")
				continue
			if material.get_shader_parameter(shader_property):
				var new_val = shader_properties[shader_property][0] * (1 - eow_meter) + shader_properties[shader_property][1] * eow_meter
				material.set_shader_parameter(shader_property, new_val) 
			else:
				printerr("Shader doesn't have property " + shader_property)
