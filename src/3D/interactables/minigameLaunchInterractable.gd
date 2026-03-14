class_name MinigameLaunchInterractable extends Interractable

@export var minigame:PackedScene

func _ready() -> void:
	function_on_interract = MainCommunicator.send_signal_to_main.bind("show minigame", minigame)
	
	super()
