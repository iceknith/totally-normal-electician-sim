extends Minigame

func _on_button_pressed() -> void:
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.SHOW_GAME3D)
