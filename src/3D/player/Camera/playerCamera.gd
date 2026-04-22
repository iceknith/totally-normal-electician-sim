class_name PlayerCamera extends Camera3D

var turnCamera:bool

@export var look_sensitivity : float = 0.006
@onready var default_fov:float = fov
@onready var default_rotation:Vector3

var rotation_y = 0
var rotation_x = 0

var shaking:bool
var shake_strength:float = 0.05
var shake_fade:float = 10

func _ready():
	setup_signals()

func setup_signals():
	MainCommunicator.signalCamera.connect(callv)

func _process(delta):
	if shaking : 
		shake()

func turn_to_look_at(ToTurnTo : Vector3, turnTime: float = 1) -> void:
	default_rotation = global_rotation
	var target_transform = global_transform.looking_at(ToTurnTo) # Calcule la rotation que doit avoir la cam pour regarder un objet
	var rotation_vector = target_transform.basis.get_euler() # La rotation final
	var tween = create_tween()
	tween.tween_property(self, "global_rotation",rotation_vector, turnTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

func zoom_in(zoom_in_time:float = 1, zoom_intensity:float = 1): 
	var tween = create_tween()
	tween.tween_property(self, "fov", default_fov - zoom_intensity, zoom_in_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

func zoom_out(zoom_out_time = 2):
	var tween = create_tween()
	tween.tween_property(self, "fov", default_fov, zoom_out_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished

func turn_then_zoom(ToTurnTo : Vector3, turnTime:float = 2, zoom_time:float = 1, zoom_intensity:float = 1) : 
	await turn_to_look_at(ToTurnTo, turnTime)
	zoom_in(zoom_time, zoom_intensity)

func turn_while_zoom(ToTurnTo : Vector3, turnTime:float = 1, zoom_time:float = 1, zoom_intensity:float = 1) : 
	default_rotation = global_rotation
	
	var target_transform = global_transform.looking_at(ToTurnTo, Vector3.UP)
	var rotation_vector = target_transform.basis.get_euler()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_rotation", rotation_vector, turnTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "fov", fov - zoom_intensity, turnTime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	return tween

func reset(time:float = 0.3):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_rotation",default_rotation, time)
	tween.parallel().tween_property(self, "fov", default_fov, time)

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
