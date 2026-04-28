class_name Aim extends Node2D


@export var aim_acceleration:int = 5

func _ready():
	$ProgressBar.visible = false
	
func manage_aim(input_direction:Vector2, delta:float):
	global_rotation = lerp_angle(global_rotation, input_direction.angle(),delta*0.5*aim_acceleration)
	return global_rotation
	
func set_visibility(v:bool):
	$ProgressBar.visible = v

func set_progress_bar_position(p:Vector2):
	$ProgressBar.global_position = p + Vector2(0, 0)  #centers the progress bar
	
func set_progress_bar_value(v:float):
	$ProgressBar.value = v
