class_name MinigameLaunchInterractable extends Interractable

@export var minigame:PackedScene

func _ready() -> void:
	function_on_interract = MainCommunicator.send_signal_to_main.bind(
		MainCommunicator.SignalType.SHOW_MINIGAME, minigame
	)
	
	super()
