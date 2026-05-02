extends Minigame

var is_listening:bool
var listening_button:Button

func _ready() -> void:
	super()
	connect_signals()

func connect_signals() -> void:
	%ButtonExit.pressed.connect(
		MainCommunicator.send_signal_to_main.bind(
			MainCommunicator.SignalType.REMOVE_MINIGAME
		)
	)
	for key_button in %Keys.get_children():
		if key_button as Button:
			key_button.text = GlobalVars.get_action_controls(key_button.name)
			key_button.pressed.connect(start_listening_keys.bind(key_button))

func _unhandled_input(event: InputEvent) -> void:
	if is_listening:
		if event as InputEventKey:
			end_listening_keys(event)

func start_listening_keys(key_button:Button) -> void:
	is_listening = true
	listening_button = key_button
	key_button.text = "..."
	
	for button in %Keys.get_children():
		if button as Button: 
			button.disabled = true

func end_listening_keys(new_event:InputEventKey) -> void:
	is_listening = false
	var action_name:String = listening_button.name
	if InputMap.has_action(action_name):
		InputMap.action_erase_events(action_name)
		InputMap.action_add_event(action_name, new_event)
	
	listening_button.text = GlobalVars.get_action_controls(action_name)
	GlobalVars.action_changed.emit(action_name)
	for button in %Keys.get_children():
		if button as Button: 
			button.disabled = false
