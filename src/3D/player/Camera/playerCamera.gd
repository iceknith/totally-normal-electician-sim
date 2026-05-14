class_name PlayerCamera extends Camera3D

var turnCamera:bool

@export var look_sensitivity : float = 0.006
@onready var default_fov:float = fov

var applied_rotation:Vector3 = Vector3.ZERO

var shaking:bool
var shake_strength:float = 0.05
var shake_fade:float = 10

var tween:Tween
@onready var player:Player = get_parent().get_parent()

func _ready():
	setup_signals()

func setup_signals():
	MainCommunicator.signalCamera.connect(callv)

func _process(delta):
	if shaking : 
		shake()

func turn_to_look_at(ToTurnTo: Vector3, turnTime: float = 1.0) -> void:
	var start_basis = global_transform.basis
	var target_transform = global_transform.looking_at(ToTurnTo, Vector3.UP)
	var target_basis = target_transform.basis

	if tween:
		tween.kill()

	tween = create_tween()

	tween.tween_method(
		func(value):
			global_transform.basis = start_basis.slerp(target_basis, value).orthonormalized(),
		0.0,
		1.0,
		turnTime
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished

func zoom_in(zoom_in_time:float = 1, zoom_intensity:float = 1): 
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "fov", default_fov - zoom_intensity, zoom_in_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

func zoom_out(zoom_out_time = 2):
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "fov", default_fov, zoom_out_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

func turn_then_zoom(ToTurnTo : Vector3, turnTime:float = 2, zoom_time:float = 1, zoom_intensity:float = 1) : 
	await turn_to_look_at(ToTurnTo, turnTime)
	zoom_in(zoom_time, zoom_intensity)
	

func turn_while_zoom(ToTurnTo: Vector3, turnTime: float = 1.0, zoom_time: float = 1.0, zoom_intensity: float = 1.0):
	var start_basis = global_transform.basis
	var target_transform = global_transform.looking_at(ToTurnTo, Vector3.UP)
	var target_basis = target_transform.basis

	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_parallel(true)

	tween.tween_method(
		func(value):
			global_transform.basis = start_basis.slerp(target_basis, value).orthonormalized(),
		0.0,
		1.0,
		turnTime
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "fov", fov - zoom_intensity, zoom_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	await tween.finished
	return tween
	
	
func reset(time:float = 0.3):
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation", Vector3(player.rotation_x + player.initRotation.x, 0, 0), time)
	tween.parallel().tween_property(self, "fov", default_fov, time)
	
	applied_rotation = Vector3.ZERO

func start_shake(shaking_strength:float):
	shake_strength = shaking_strength
	shaking = true

func end_shake(shaking_fade:float):
	shake_fade = shaking_fade
	shaking = false

func shake():
	if shake_strength > 0 : 
		h_offset = randf_range(-shake_strength, shake_strength)
		v_offset = randf_range(-shake_strength, shake_strength)

func shake_for(shake_strength, shake_duration):
	shaking = true
	await get_tree().create_timer(shake_duration).timeout
	shaking = false
