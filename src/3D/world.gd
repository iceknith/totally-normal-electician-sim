extends Node3D

var eow_meter:float = 0:
	set(new_val):
		eow_meter = new_val
		update_eow()

@export var sunStartAngle:float = -10
@export var sunEndAngle:float = -170

@export var skyTopStartAngle:Color
@export var skyBotStartAngle:Color
@export var skyTopEndtAngle:Color
@export var skyBotEndtAngle:Color
@export var skyChangeCurve:Curve

@onready var skyMaterial:ProceduralSkyMaterial = $WorldEnvironment.environment.sky.sky_material

func update_eow():
	$Sun.rotation_degrees.x = sunStartAngle * (1 - eow_meter) + sunEndAngle * eow_meter
	
