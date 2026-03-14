extends Node

signal signalMain(type:String, content)

func send_signal_to_main(type:String, content=null):
	signalMain.emit(type, content)
