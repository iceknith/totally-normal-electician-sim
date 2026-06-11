class_name CameraManager extends Node3D

@export var player:Player 
var player_camera:Camera3D

func _ready():
	player_camera = find_camera()

	if player_camera == null:
		push_error("Aucune Camera3D trouvée dans player.")
		
	setup_signals()
		
	
		

func find_camera() -> Camera3D:
	if player == null:
		push_error("Player non assigné.")
		return null

	return _find_camera_recursive(player)


func _find_camera_recursive(node: Node) -> Camera3D:
	if node is Camera3D:
		return node as Camera3D

	for child in node.get_children():
		var found_camera := _find_camera_recursive(child)
		if found_camera != null:
			return found_camera
	return null
	
func setup_signals():
	MainCommunicator.switchToPlayerCamera.connect(switch_back_to_player_cam)


func switch_camera(camera_path):
	var camera := get_node_or_null(camera_path) as Camera3D

	if camera == null:
		push_error("Camera introuvable : " + str(camera_path))
		return

	camera.make_current()
	
func switch_back_to_player_cam():
	player_camera.make_current()
