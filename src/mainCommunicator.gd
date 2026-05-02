extends Node


enum SignalType {
	ADD_MINIGAME,
	REMOVE_MINIGAME,
	SHOW_GAME3D,
	START_DIALOGUE,
	IN_INTERACTION
}

enum GameState {
	StartMenu,
	Game3D,
	MiniGame,
	EndMenu,
}

var current_state:GameState = GameState.Game3D
var is_in_dialogue:bool = false

signal ChangeGameState(newState:GameState)
signal signalMain(type, content) 
signal signalCamera(callable:String, arguments)

func send_signal_to_main(type, content=null):
	signalMain.emit(type, content)
