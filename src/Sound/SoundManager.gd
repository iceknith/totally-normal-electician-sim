extends Node

var music_volume:int
var sfx_volume:int

signal change_music(music_name)
signal change_music_volume(new_volume)
signal stop_music(fade_duration)
signal change_sfx_volume(new_volume)
signal reset_music(music_name)
