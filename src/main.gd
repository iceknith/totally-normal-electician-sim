extends Node3D

enum GameState {
	StartMenu,
	Game3D,
	Dialogue,
	MiniGame,
	EndMenu,
}

signal eow_meter_changed(new_eow_var:float)

@export var end_of_world_max_time_mins:float = 20
@export var end_of_world_change_interval_s:float = 0.5
@onready var eow_delta:float = end_of_world_change_interval_s / (end_of_world_max_time_mins * 60)
var eow_meter:float:
	set(new_val):
		eow_meter = new_val

@onready var world3D:Node3D = $World
@onready var minigame_container:Control = $HUD/Minigames

var currentState:GameState = GameState.Game3D

func _ready() -> void:
	connect_signals()
	reset_state()
	create_eow_timers()

func connect_signals():
	MainCommunicator.signalMain.connect(receive_signal)
	

func receive_signal(type, data):
	print("received signal")
	match type: #pour l'instant je vais pas toucher à ça parce que je veux pas tout casser
		"show minigame": show_minigame(data)
		"show game3D": show_game3D()
		MainCommunicator.SignalType.START_DIALOGUE : start_dialogue(data)
	

func reset_state():
	# Reset minigames
	minigame_container.hide()
	if currentState == GameState.MiniGame:
		for child in minigame_container.get_children():
			child.queue_free()
	
	# TODO, implémenter les resets de menus & dialogues
	
	# Reset state
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	currentState = GameState.Game3D
	
	# Show & process world3D
	world3D.show()
	world3D.process_mode = Node.PROCESS_MODE_INHERIT

func show_minigame(minigameScene:PackedScene):
	# Reset state to normalized state
	reset_state()
	
	# Change GameState
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	currentState = GameState.MiniGame
	
	# Show minigame
	var minigame:Minigame = minigameScene.instantiate()
	minigame.miniGameEnd.connect(show_game3D)
	minigame_container.show()
	minigame_container.add_child(minigame)
	
	# Stop process from game
	world3D.process_mode = Node.PROCESS_MODE_DISABLED

func show_game3D():
	reset_state()

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
	
	for child in node.get_children():
		if child.get("eow_meter") != null:
				timer_timeout.connect(increment_eow_meter.bind(child))
		connect_eow_update_timer(child, timer_timeout)

func increment_eow_meter(node:Node):
	node.eow_meter += eow_delta

func update_game_state(state:GameState):
	currentState = state

func start_dialogue(dialogueFile:String):
	DialogueManager.show_example_dialogue_balloon(load(dialogueFile))

func end_of_world():
	print("world ended")
