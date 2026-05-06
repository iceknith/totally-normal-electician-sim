extends AudioStreamPlayer2D


@onready var caught_sfx = load("res://src/minigames/arcadeGame/soundEffects/Caught.wav")
@onready var launch_sfx = load("res://src/minigames/arcadeGame/soundEffects/Launch.wav")
func play_clip(entity, clip):
	match clip : 
		"caught":
			volume_db = -7
			stream = caught_sfx
		"launched":
			volume_db = -12
			stream = launch_sfx
	pitch_scale = randf_range(0.5, 2.5)
	play()
