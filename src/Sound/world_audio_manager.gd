class_name WorldAudioManager extends Node
@onready var bg_music_player:AudioStreamPlayer = $BackgroundMusicPlayer
@export var default_music:String = "MainTheme"
var music_pitch:float = 1
var music_tempo:float = 1
var music_folder:String = "res://src/Sound/Musics/"
var bus_idx = AudioServer.get_bus_index("music")

var music_positions:Dictionary = {}
var current_music:String = ""

func _ready():
	update_music(default_music)
	SoundManager.change_music.connect(update_music)
	MainCommunicator.ChangeGameState.connect(back_to_main_theme)

func _process(delta):
	pass

func update_music(music:String):
	var path = music_folder + music + ".ogg"
	if not ResourceLoader.exists(path):
		push_error("Music file not found: " + path)
		return
	
	# sauvegarde la position de la musique actuelle
	if current_music != "":
		music_positions[current_music] = bg_music_player.get_playback_position()
	
	bg_music_player.stop()
	bg_music_player.stream = load(path) as AudioStreamOggVorbis
	bg_music_player.stream.loop = true
	bg_music_player.play()
	
	# reprend à l'emplacement de la musique si on l'a déjà save
	if music_positions.has(music):
		bg_music_player.seek(music_positions[music])
	
	current_music = music

func back_to_main_theme(state):
	if state == MainCommunicator.GameState.Game3D:
		update_music(default_music)

func get_music_stream():
	return bg_music_player

func modify_music_pitch(new_pitch:float):
	var pitch_effect: AudioEffectPitchShift = AudioServer.get_bus_effect(bus_idx, 0)
	pitch_effect.pitch_scale = new_pitch / bg_music_player.pitch_scale

func modify_music_tempo(new_tempo:float):
	bg_music_player.pitch_scale = new_tempo
