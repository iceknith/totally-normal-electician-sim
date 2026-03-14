extends Minigame


func _on_button_pressed() -> void:
	MainCommunicator.send_signal_to_main("show game3D")
