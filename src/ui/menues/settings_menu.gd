class_name SettingsMenu extends Minigame

@export var keys_settings_menu:PackedScene = preload("res://src/ui/menues/keys_settings_menu.tscn")
@export var sound_settings_menu:PackedScene = preload("res://src/ui/menues/sound_settings_menu.tscn")

func _ready() -> void:
	super()
	connect_signals()

func connect_signals() -> void:
	%ButtonKeys.pressed.connect(
		MainCommunicator.send_signal_to_main.bind(
			MainCommunicator.SignalType.ADD_MINIGAME, 
			[keys_settings_menu, {} as Dictionary[String, Callable]]
		)
	)
	%ButtonSound.pressed.connect(
		MainCommunicator.send_signal_to_main.bind(
			MainCommunicator.SignalType.ADD_MINIGAME, 
			[sound_settings_menu, {} as Dictionary[String, Callable]]
		)
	)
	%ButtonExit.pressed.connect(
		MainCommunicator.send_signal_to_main.bind(
			MainCommunicator.SignalType.REMOVE_MINIGAME
		)
	)
