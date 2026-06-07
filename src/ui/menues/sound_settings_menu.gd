extends Minigame

@onready var master_volume_slider = $PanelContainer/MarginContainer/VBoxContainer/MasterVolume

@onready var music_volume_slider =$PanelContainer/MarginContainer/VBoxContainer/MusicVolume
@onready var sfx_volume_slider = $PanelContainer/MarginContainer/VBoxContainer/SFXVolume


var music_bus_idx = AudioServer.get_bus_index("music")
var sfx_bus_idx = AudioServer.get_bus_index("sfx")
var master_bus_idx = AudioServer.get_bus_index("Master")

func _ready() -> void:
	master_volume_slider.value = AudioServer.get_bus_volume_db(master_bus_idx)
	music_volume_slider.value = AudioServer.get_bus_volume_db(music_bus_idx)
	sfx_volume_slider.value = AudioServer.get_bus_volume_db(sfx_bus_idx)

	
func _on_music_volume_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus_idx, value)


func _on_sfx_volume_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus_idx, value)


func _on_button_exit_pressed():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)


func _on_master_volume_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus_idx, value)
