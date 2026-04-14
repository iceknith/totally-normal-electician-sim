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
@onready var worldBoxSmall:Area3D = $worldBoxSmall
@onready var worldBoxBig:Area3D = $worldBoxBig


func _ready() -> void:
	GlobalVars.tower_amount = count_towers(self)
	worldBoxBig.body_exited.connect(_on_body_leave_world_box_big)

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

func _on_body_leave_world_box_big(body:Node3D):
	# Get nearest point
	var initPos:Vector3 = body.global_position
	initPos[body.global_position.abs().max_axis_index()] = 0
	var query:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		initPos, body.global_position, 0b10000000, []
	)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.hit_back_faces = true
	#query.hit_from_inside = true
	
	var collision = get_world_3d().direct_space_state.intersect_ray(query)
	
	if collision:
		body.global_position = collision.position
	#else: printerr("Object out of world bounds error: No small box found")
	
