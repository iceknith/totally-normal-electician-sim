extends Node


#je pose ça là en attendant pour pas toucher le main et vu que c'est en autoload c'est plus simple
signal signalMain(type:String, content)
func send_signal_to_main(type:String, content=null):
	signalMain.emit(type, content)
