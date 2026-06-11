extends ColorRect


func _ready():
	modulate = Color.TRANSPARENT
	setup_signals()
	
func setup_signals():
	MainCommunicator.fadeIn.connect(fadeIn)
	MainCommunicator.fadeOut.connect(fadeOut)
	
func fadeIn(fade_duration:float):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color.BLACK, fade_duration)
	await tween.finished
	MainCommunicator.fadeFinished.emit()

func fadeOut(fade_duration:float):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_duration)
	await tween.finished
	MainCommunicator.fadeFinished.emit()
