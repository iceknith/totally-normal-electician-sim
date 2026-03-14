extends Camera3D




const CAMERA_SENS = 0.003


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
func _input(event):
	if event is InputEventMouseMotion : 
		rotation.y -= event.relative.x * CAMERA_SENS
		rotation.x -= event.relative.y * CAMERA_SENS
		
		
		
	
