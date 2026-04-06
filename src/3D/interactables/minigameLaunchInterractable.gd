class_name MinigameLaunchInterractable extends Interractable

@export var minigame:PackedScene
@export var connections:Dictionary[String, Callable]

func _ready() -> void:
	function_on_interract =  func():
		await interaction_animation()
		MainCommunicator.send_signal_to_main(
			MainCommunicator.SignalType.SHOW_MINIGAME, [minigame, connections]
		)
	super()
