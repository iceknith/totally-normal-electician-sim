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
	$VBoxContainer/ButtonQuit.pressed.connect(
		get_tree().quit
	)

func remove() -> void:
	# Disable process for all children
	for child in get_children(): child.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Define Tween
	var hide_tween:Tween = create_tween()
	hide_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	# Add properties
	hide_tween.tween_property(self, "modulate", Color(1,1,1,0), animationDuration)
	hide_tween.tween_callback(queue_free)
