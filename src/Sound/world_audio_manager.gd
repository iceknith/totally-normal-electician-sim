class_name WorldAudioManager extends Node
@onready var bg_music_player:AudioStreamPlayer = $BackgroundMusicPlayer
@export var default_music:String = "MainTheme"

@export_group("EOW Distortion")
@export var pitch_curve:Curve
@export var tempo_curve:Curve

@export_group("Music Transition")
@export var music_fade_out_duration: float = 0.4
@export var music_fade_in_duration: float = 0.6
@export var music_silence_volume_db: float = -80.0

@export_group("End Of World Music")
@export var eow_music:AudioStream
@export var eow_music_fadeout_time:float = 30
@export var eow_silence_time:float = 30
@export var eow_music_start_time:float = 40
var eow_music_start_perc:float
var eow_music_playing:bool = false

var music_base_volume_db: float = 0.0
var music_transition_tween: Tween
var music_transition_id: int = 0

var eow_meter:float = 0:
	set(new_val):
		eow_meter = new_val
		if eow_meter > eow_music_start_perc:
			start_eow_music()
		else:
			modify_music_pitch(pitch_curve.sample(eow_meter))
			modify_music_tempo(tempo_curve.sample(eow_meter))

var music_pitch:float = 1
var music_tempo:float = 1
var music_folder:String = "res://src/Sound/Musics/"
var bus_idx = AudioServer.get_bus_index("music")

var music_positions:Dictionary = {}
var current_music:String = ""

func _ready():
	music_base_volume_db = bg_music_player.volume_db
	SoundManager.change_music.connect(update_music)
	SoundManager.stop_music.connect(stop_music)
	MainCommunicator.ChangeGameState.connect(back_to_main_theme)
	SoundManager.reset_music.connect(reset_music)
	
	await get_tree().process_frame
	eow_music_start_perc = 1 - (eow_music_start_time + eow_silence_time + eow_music_fadeout_time) / GlobalVars.eow_max_time_s

func update_music(music:String):
	if eow_music_playing: return
	
	var path = music_folder + music + ".ogg"
	if not ResourceLoader.exists(path):
		push_error("Music file not found: " + path)
		return
	
	if music == current_music: #pour éviter d'avoir plusieurs music transition en même temps
		return
	
	music_transition_id += 1
	var transition_id = music_transition_id
	
	if music_transition_tween != null:
		music_transition_tween.kill()
	
	# fade out seulement si une musique est déjà en train de jouer
	if bg_music_player.playing:
		music_transition_tween = create_tween()
		music_transition_tween.tween_property(
			bg_music_player,
			"volume_db",
			music_silence_volume_db,
			music_fade_out_duration
		)
		await music_transition_tween.finished
		
		if transition_id != music_transition_id:
			return
	
	# sauvegarde la position de la musique actuelle
	if current_music != "":
		music_positions[current_music] = bg_music_player.get_playback_position()
	
	bg_music_player.stop()
	bg_music_player.stream = load(path) as AudioStreamOggVorbis
	bg_music_player.stream.loop = true
	bg_music_player.volume_db = music_silence_volume_db
	bg_music_player.play()
	
	# reprend à l'emplacement de la musique si on l'a déjà save
	if music_positions.has(music):
		bg_music_player.seek(music_positions[music])
	
	current_music = music
	
	# fade in de la nouvelle musique
	music_transition_tween = create_tween()
	music_transition_tween.tween_property(
		bg_music_player,
		"volume_db",
		music_base_volume_db,
		music_fade_in_duration
	)

func back_to_main_theme(state):
	if state == MainCommunicator.GameState.Game3D:
		update_music(default_music)

func get_music_stream():
	return bg_music_player

func start_eow_music():
	if !eow_music_playing:
		eow_music_playing = true
		if music_transition_tween != null: music_transition_tween.kill()
		music_transition_tween = create_tween()
		
		music_transition_tween.tween_property(
			bg_music_player, 
			"volume_db", 
			music_silence_volume_db, 
			eow_music_fadeout_time
			)
		music_transition_tween.tween_callback(bg_music_player.stop)
		music_transition_tween.tween_interval(eow_silence_time)
		await music_transition_tween.finished
		
		bg_music_player.bus = "end of world"
		bg_music_player.stream = eow_music
		bg_music_player.volume_db = music_base_volume_db
		bg_music_player.play(0)

func modify_music_pitch(new_pitch:float):
	var pitch_effect: AudioEffectPitchShift = AudioServer.get_bus_effect(bus_idx, 0)
	pitch_effect.pitch_scale = new_pitch / bg_music_player.pitch_scale

func modify_music_tempo(new_tempo:float):
	bg_music_player.pitch_scale = new_tempo

func reset_music(music:String):
	if eow_music_playing: return
	if music_positions.has(music):
		music_positions[music] = 0
		
func stop_music(fade_duration: float = 0.6):
	if eow_music_playing: return
	music_transition_id += 1
	var transition_id = music_transition_id
	
	if music_transition_tween != null:
		music_transition_tween.kill()
	
	if !bg_music_player.playing:
		return
	
	if current_music != "":
		music_positions[current_music] = bg_music_player.get_playback_position()
	
	music_transition_tween = create_tween()
	music_transition_tween.tween_property(
		bg_music_player,
		"volume_db",
		music_silence_volume_db,
		fade_duration
	)
	
	await music_transition_tween.finished
	
	if transition_id != music_transition_id:
		return
	
	bg_music_player.stop()
	bg_music_player.volume_db = music_base_volume_db
	current_music = ""
