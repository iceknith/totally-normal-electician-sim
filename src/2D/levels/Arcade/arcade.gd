extends Minigame

func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)


func _on_exit_body_entered(body):
	exit()
