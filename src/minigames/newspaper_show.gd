extends Minigame

@export var texture:Texture

func _ready() -> void:
	super()
	if texture:
		%TextureRect.texture = texture

func _on_exit_pressed() -> void:
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)
