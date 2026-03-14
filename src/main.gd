extends Node3D

enum GameState {
	StartMenu,
	Game3D,
	Dialogue,
	MiniGame,
	EndMenu,
}

@onready var world3D:Node3D = $World
@onready var minigame_container:Control = $HUD/Minigames

var currentState:GameState = GameState.Game3D

func _ready() -> void:
	MainCommunicator.signalMain.connect(recieve_signal)
	reset_state()

func recieve_signal(type:String, data):
	match type:
		"show minigame": show_minigame(data)
		"show game3D": show_game3D()
		_: pass

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
