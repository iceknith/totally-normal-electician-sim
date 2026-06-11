class_name CameraManager extends Node3D

@export var player:Player 
var player_camera:Camera3D

func _ready():
	player_camera = player.get_camera()

	if player_camera == null:
		push_error("Aucune Camera3D trouvée dans player.")
		
	setup_signals()
		
	
		


func setup_signals():
	MainCommunicator.switchToPlayerCamera.connect(switch_back_to_player_cam)


func switch_camera(camera_path):
	print(camera_path)
	print($"../Player".global_position)
	var camera := get_node_or_null(camera_path) as Camera3D

	if camera == null:
		push_error("Camera introuvable : " + str(camera_path))
		return

	camera.make_current()
	print(camera.name)
	
func switch_back_to_player_cam():
	player_camera.make_current()
	
