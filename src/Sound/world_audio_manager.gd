class_name WorldAudioManager extends Node

@onready var bg_music_player:AudioStreamPlayer = $BackgroundMusicPlayer
@export var default_music:String = "MainWorld"

func _ready():
	update_music(default_music)
	SoundManager.change_music.connect(update_music)
	MainCommunicator.ChangeGameState.connect(back_to_main_theme)

func _process(delta):
	pass
	
func update_music(music:String):
	bg_music_player["parameters/switch_to_clip"] = music

func back_to_main_theme(state):
	if state == MainCommunicator.GameState.Game3D :
			update_music(default_music)

	
	
