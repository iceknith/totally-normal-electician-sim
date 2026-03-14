extends Camera3D


var turnCamera:bool

@export var default_fov:float = 75
@export var look_sensitivity : float = 0.006


var rotation_y = 0
var rotation_x = 0 

func _ready():
	pass
	
	
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
		
	
func zoom_out(zoom):
	pass
		
func turn_then_zoom(ToTurnTo : Vector3, turnTime:float, zoom_time:float, zoom_intensity:float) : 
	turn_to_look_at(ToTurnTo, turnTime)
	zoom_in(zoom_time, zoom_intensity)
	
func turn_while_zoom(ToTurnTo : Vector3, turnTime:float, zoom_time:float, zoom_intensity:float) : 
	var target_transform = global_transform.looking_at(ToTurnTo) # Calcule la rotation que doit avoir la cam pour regarder un objet
	var rotation_vector = target_transform.basis.get_euler() # La rotation qui va évoluer
	var start_rotation = global_rotation #La rotation de départ de la cam
	
	for i in range(60):
		var t = (i+1)/ 60.0
		global_rotation = start_rotation.lerp(rotation_vector, t)
		fov -= zoom_intensity
		await get_tree().create_timer(turnTime / 60.0).timeout
		


		

		
			
	

		
		

	

	
	
