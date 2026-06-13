extends Node

var music_volume:int
var sfx_volume:int

signal change_music(music_name)

signal stop_music(fade_duration)
signal reset_music(music_name)

signal play_sfx(sfxPath:String)
