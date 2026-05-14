extends Control

func _ready() -> void:
	$Exit.pressed.connect(_on_exit_pressed)


func _on_exit_pressed() -> void:
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)
