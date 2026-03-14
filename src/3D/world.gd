extends Node3D

var eow_meter:float = 0:
	set(new_val):
		eow_meter = new_val
		update_eow()

@export var sunStartAngle:float = -10
@export var sunEndAngle:float = -170


func update_eow():
	$Sun.rotation_degrees.x = sunStartAngle * (1 - eow_meter) + sunEndAngle * eow_meter
