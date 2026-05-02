extends Node


#je pose ça là en attendant pour pas toucher le main et vu que c'est en autoload c'est plus simple
enum SignalType {
	LAUNCH_GAME,
	ADD_MINIGAME,
	REMOVE_MINIGAME,
	SHOW_GAME3D,
	START_DIALOGUE,
	IN_INTERACTION
}

enum GameState {
	Game3D,
	MiniGame,
}

var current_state:GameState = GameState.Game3D
var is_in_dialogue:bool = false

signal signalMain(type, content) 
signal signalCamera(callable:String, arguments)

func send_signal_to_main(type, content=null):
	signalMain.emit(type, content)
