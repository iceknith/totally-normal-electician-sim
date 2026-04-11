extends Node


#je pose ça là en attendant pour pas toucher le main et vu que c'est en autoload c'est plus simple
enum SignalType {
	CHANGE_GAMESTATE,
	ADD_MINIGAME,
	REMOVE_MINIGAME,
	SHOW_GAME3D,
	START_DIALOGUE,
	IN_INTERACTION, 
	RESET_CAMERA
}

enum GameState {
	StartMenu,
	Game3D,
	Dialogue,
	MiniGame,
	EndMenu,
}

var current_state:GameState = GameState.Game3D

signal signalMain(type, content) 



func send_signal_to_main(type, content=null):
	signalMain.emit(type, content)
	
