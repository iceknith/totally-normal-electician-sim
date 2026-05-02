extends Minigame

@export var settings_menu:PackedScene = preload("res://src/ui/menues/settings_menu.tscn")

func _ready() -> void:
	connect_signals()

func connect_signals():
	$VBoxContainer/ButtonPlay.pressed.connect(
		MainCommunicator.send_signal_to_main.bind(MainCommunicator.SignalType.LAUNCH_GAME)
	)
	$VBoxContainer/ButtonOptions.pressed.connect(
		MainCommunicator.send_signal_to_main.bind(
			MainCommunicator.SignalType.ADD_MINIGAME, 
			[settings_menu, {} as Dictionary[String, Callable]]
		)
	)
