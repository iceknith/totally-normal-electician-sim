extends Node3D

var eow_meter:float = 0:
	set(new_val):
		eow_meter = new_val
		update_eow()

@export var sunStartAngle:float = -10
@export var sunEndAngle:float = -170

@export var skyTopStartColor:Color
@export var skyBotStartColor:Color
@export var skyTopEndColor:Color
@export var skyBotEndColor:Color
@export var skyChangeCurve:Curve

@onready var skyMaterial:ProceduralSkyMaterial = $WorldEnvironment.environment.sky.sky_material

func _ready() -> void:
	GlobalVars.tower_amount = count_towers(self)
	print(GlobalVars.tower_amount)

func update_eow():
	$Sun.rotation_degrees.x = sunStartAngle * (1 - eow_meter) + sunEndAngle * eow_meter
	
	var skyChangeProgress:float = skyChangeCurve.sample(eow_meter)
	skyMaterial.sky_top_color = skyTopStartColor * (1 - skyChangeProgress) + skyTopEndColor * skyChangeProgress
	skyMaterial.sky_horizon_color = skyBotStartColor * (1 - skyChangeProgress) + skyBotEndColor * skyChangeProgress


func count_towers(node:Node) -> int:
	var result = 0
	if node:
		for child in node.get_children():
			if child as Tower: result += 1
			else: result += count_towers(child)
		
	return result
