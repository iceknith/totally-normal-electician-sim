extends Node2D


@export var aim_acceleration:int = 5


func manage_aim(input_direction:Vector2, delta:float):
	global_rotation = lerp_angle(global_rotation, input_direction.angle(),delta*0.5*aim_acceleration)
	return global_rotation
	
func set_visibility(v:bool):
	$ProgressBar.visible = v
