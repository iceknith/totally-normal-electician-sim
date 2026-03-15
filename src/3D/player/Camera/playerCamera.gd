extends Camera3D


var turnCamera:bool

@export var default_fov:float = 75
@export var look_sensitivity : float = 0.006


var rotation_y = 0
var rotation_x = 0
 
var shaking:bool
var shake_strength:float = 0.05
var shake_fade:float = 10

func _ready():
	pass
	
func _process(delta):
	if shaking : 
		shake()
	
func turn_to_look_at(ToTurnTo : Vector3, turnTime: float = 1) -> void:

	var target_transform = global_transform.looking_at(ToTurnTo) # Calcule la rotation que doit avoir la cam pour regarder un objet
	var rotation_vector = target_transform.basis.get_euler() # La rotation qui va évoluer
	var start_rotation = global_rotation #La rotation de départ de la cam
	
	for i in range(60):
		var t = (i+1)/ 60.0
		global_rotation = start_rotation.lerp(rotation_vector, t)
		await get_tree().create_timer(turnTime / 60.0).timeout
	
func zoom_in(zoom_time:float = 1, zoom_intensity:float = 1): 
	for i in range(60):
		fov -= zoom_intensity
		await get_tree().create_timer(zoom_time / 60.0).timeout
		
	
func zoom_out(zoom_out_time = 1):
	var starting_fov = fov
	for i in range(60):
		var t = (i+1)/60
		fov = lerp(starting_fov, default_fov, t)
		await get_tree().create_timer(zoom_out_time / 60.0).timeout
		
func turn_then_zoom(ToTurnTo : Vector3, turnTime:float = 2, zoom_time:float = 1, zoom_intensity:float = 1) : 
	await turn_to_look_at(ToTurnTo, turnTime)
	zoom_in(zoom_time, zoom_intensity)
	
func turn_while_zoom(ToTurnTo : Vector3, turnTime:float = 1, zoom_time:float = 1, zoom_intensity:float = 1) : 
	var target_transform = global_transform.looking_at(ToTurnTo) # Calcule la rotation que doit avoir la cam pour regarder un objet
	var rotation_vector = target_transform.basis.get_euler() # La rotation qui va évoluer
	var start_rotation = global_rotation #La rotation de départ de la cam
	
	for i in range(60):
		var t = (i+1)/ 60.0
		global_rotation = start_rotation.lerp(rotation_vector, t)
		fov -= zoom_intensity
		await get_tree().create_timer(turnTime / 60.0).timeout
		

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
		
		
		
func lock_camera(): 
	MainCommunicator.lock_camera = true
	
func unlock_camera():
	MainCommunicator.lock_camera = false
	
	
	
	



		

		
			
	

		
		

	

	
	
