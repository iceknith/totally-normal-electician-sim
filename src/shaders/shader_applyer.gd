extends ColorRect

@export var shader_properties:Dictionary[String, Array]

var eow_meter:float = 0:
	set(new_val):
		eow_meter = new_val
		update_eow()

func update_eow():
	if (material as ShaderMaterial) and (material.shader):
		for shader_property in shader_properties.keys():
			if not shader_properties[shader_property].size() in [2,3]:
				printerr("Currently only supports interpolation between two values and a curve")
				continue
			var effective_eow_meter:float = eow_meter
			if shader_properties[shader_property].size() == 3:
				var curve:Curve = shader_properties[shader_property][2]
				effective_eow_meter = curve.sample(effective_eow_meter)
			if material.get_shader_parameter(shader_property) != null:
				var new_val = shader_properties[shader_property][0] * (1 - effective_eow_meter) + shader_properties[shader_property][1] * effective_eow_meter
				material.set_shader_parameter(shader_property, new_val) 
			else:
				printerr("Shader doesn't have property " + shader_property)
