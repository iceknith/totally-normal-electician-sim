extends Minigame

@export var eow_delay:float = 10
@export var eow_playing_time:float = 38.8

func _ready() -> void:
	super()
	get_tree().create_timer(eow_delay).timeout.connect(start_eow_music)

func start_eow_music():
	$EOW_Player.play()
	get_tree().create_timer(eow_playing_time).timeout.connect(end_of_world)

func end_of_world():
	MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.TRIGGER_END_OF_WORLD,
		null
		)
	SoundManager.stop_music.emit()
