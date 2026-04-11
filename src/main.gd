extends Node3D

enum GameState {
	StartMenu,
	Game3D,
	Dialogue,
	MiniGame,
	EndMenu,
}

signal eow_meter_changed(new_eow_var:float)

@export_group("end of world meter (eow_meter)")
@export var end_of_world_max_time_mins:float = 20
@export var end_of_world_change_interval_s:float = 0.1
@onready var eow_delta:float = end_of_world_change_interval_s / (end_of_world_max_time_mins * 60)
var eow_meter:float

@export_group("mouse jitter")
@export var has_mouse_jitter:bool = true
@export var mouse_jitter_speed:float = 5
@export var mouse_jitter_intensity:Vector2 = Vector2.ONE * 10
@export var camera_jitter_amount:float = 0.8
@export var mouse_jitter_intensity_curve:Curve
@export var mouse_jitter_speed_curve:Curve
@export var mouse_jitter_noise:Noise
var mouse_noise_pos:float
var unhandled_mouse_offset:Vector2

@onready var world3D:Node3D = $World
@onready var minigame_container:Control = $HUD/Minigames
var minigames:Array[Minigame]

var currentState:GameState = GameState.Game3D

### Init ###

func _ready() -> void:
	connect_signals()
	reset_state()
	create_eow_timers()

func connect_signals():
	MainCommunicator.signalMain.connect(receive_signal)

func receive_signal(type, data):
	match type: #pour l'instant je vais pas toucher à ça parce que je veux pas tout casser
		MainCommunicator.SignalType.ADD_MINIGAME: add_minigame(data)
		MainCommunicator.SignalType.REMOVE_MINIGAME: remove_minigame()
		MainCommunicator.SignalType.SHOW_GAME3D: show_game3D()
		MainCommunicator.SignalType.START_DIALOGUE : start_dialogue(data)
		MainCommunicator.SignalType.CHANGE_GAMESTATE : update_game_state(data)

func reset_state():
	# Reset minigames
	minigame_container.hide()
	if currentState == GameState.MiniGame:
		for child in minigames:
			child.queue_free()
		minigames.clear()
	
	# TODO, implémenter les resets de menus & dialogues
	
	# Reset state
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentState = GameState.Game3D
	
	# Show & process world3D
	world3D.show()
	world3D.process_mode = Node.PROCESS_MODE_INHERIT

func create_minigame(data):
	# Show minigame
	var minigameScene:PackedScene = data[0]
	var minigame:Minigame = minigameScene.instantiate()
	minigames.append(minigame)
	minigame.miniGameEnd.connect(show_game3D)
	minigame_container.show()
	minigame_container.add_child(minigame)
	
	# Add connections
	var connections:Dictionary = data[1]
	for connection in connections.keys():
		minigame.connect(connection, connections[connection])

func add_minigame(data:Array):
	if currentState == GameState.Game3D:
		show_minigame(data)
	else:
		# Disable last minigame's Process
		minigames[-1].process_mode = Node.PROCESS_MODE_DISABLED
		
		# Add new minigame
		create_minigame(data)

func remove_minigame():
	if minigames.size() <= 1:
		show_game3D()
	else:
		# Remove last minigame
		minigames[-1].queue_free()
		minigames.pop_back()
		
		# Enable last minigame's Process
		minigames[-1].process_mode = Node.PROCESS_MODE_INHERIT

func show_minigame(data:Array):
	# Reset state to normalized state
	reset_state()
	
	# Change GameState
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	currentState = GameState.MiniGame
	
	create_minigame(data)
	
	# Stop process from game
	world3D.process_mode = Node.PROCESS_MODE_DISABLED

func show_game3D():
	reset_state()

### EOW Handlers ###

func create_eow_timers():
	var timer_eow = Timer.new()
	var timer_eow_update = Timer.new()
	
	timer_eow.timeout.connect(end_of_world)
	timer_eow.one_shot = true
	add_child(timer_eow)
	timer_eow.start(end_of_world_max_time_mins * 60)
	
	connect_eow_update_timer(self, timer_eow_update.timeout)
	add_child(timer_eow_update)
	timer_eow_update.start(end_of_world_change_interval_s)

func connect_eow_update_timer(node:Node, timer_timeout:Signal):
	if not node: return
	
	if node.get("eow_meter") != null:
		timer_timeout.connect(func(): node.eow_meter += eow_delta)
	
	for child in node.get_children():
		connect_eow_update_timer(child, timer_timeout)

func increment_eow_meter(node:Node):
	node.eow_meter += eow_delta

func update_game_state(state:MainCommunicator.GameState):
	MainCommunicator.current_state = state

func start_dialogue(data:Array):
	var dialogueFile:String = data[0]
	var title:String = data[1]
	var extra_game_states:Array = data[2]
	MainCommunicator.signalMain.emit(
	MainCommunicator.SignalType.CHANGE_GAMESTATE,\
	MainCommunicator.GameState.Dialogue)
	DialogueManager.show_dialogue_balloon(
		load(dialogueFile), title, extra_game_states
		)

func end_of_world():
	get_tree().quit()

### Runtime functions ###

func _process(delta: float) -> void:
	mouse_jitter_handler(delta)

### Mouse jitter ###

func mouse_jitter_handler(delta:float) -> void:
	if has_mouse_jitter && mouse_jitter_intensity_curve.sample(eow_meter) > 0:
		mouse_noise_pos += delta * mouse_jitter_speed * mouse_jitter_speed_curve.sample(eow_meter)
		var rand_dir:Vector2 = Vector2(
			mouse_jitter_noise.get_noise_2d(mouse_noise_pos, 0),
			mouse_jitter_noise.get_noise_2d(0, mouse_noise_pos),
		)
		var mouse_offset:Vector2 = mouse_jitter_intensity_curve.sample(eow_meter) * mouse_jitter_intensity * rand_dir * delta
		var new_mouse_pos:Vector2 = get_viewport().get_mouse_position() + mouse_offset + unhandled_mouse_offset
		unhandled_mouse_offset = new_mouse_pos - round(new_mouse_pos)
		get_viewport().warp_mouse(round(new_mouse_pos))
		
		if currentState == GameState.Game3D:
			var jitter_input = InputEventMouseMotion.new()
			jitter_input.relative = mouse_offset * camera_jitter_amount
			Input.parse_input_event(jitter_input)
