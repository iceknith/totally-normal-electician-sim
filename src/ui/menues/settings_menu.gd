class_name SettingsMenu extends Minigame

@export var keys_settings_menu:PackedScene = preload("res://src/ui/menues/keys_settings_menu.tscn")
@export var sound_settings_menu:PackedScene = preload("res://src/ui/menues/sound_settings_menu.tscn")

func _ready() -> void:
	super()
	%MouseSensitivity.value = GlobalVars.mouse_sentitivity * 1000
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
	%ButtonBack.pressed.connect(
		MainCommunicator.send_signal_to_main.bind(
			MainCommunicator.SignalType.REMOVE_MINIGAME
		)
	)
	%ButtonExit.pressed.connect(
		get_tree().quit
	)
	%MouseSensitivity.value_changed.connect(
		change_mouse_sensitivity
	)

func change_mouse_sensitivity(value:float):
	GlobalVars.mouse_sentitivity = value / 1000
