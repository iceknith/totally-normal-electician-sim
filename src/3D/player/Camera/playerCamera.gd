extends Camera3D


var turnCamera:bool

func _ready():
	pass
	
	
func turn_to_look_at(ToTurnTo : Vector3, turnTime:float = 2) -> void :
	for i in range(5):
		look_at((0.6+i*0.1)*ToTurnTo)
		await get_tree().create_timer(2/5).timeout

	
	
