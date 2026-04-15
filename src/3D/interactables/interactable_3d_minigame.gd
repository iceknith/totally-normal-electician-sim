class_name Interactable3DMinigame extends Interactable3D

@export var minigame:PackedScene
@export var connections:Dictionary[String, Callable]

func start_interaction():
	MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.ADD_MINIGAME, 
		[minigame, connections]
	)
