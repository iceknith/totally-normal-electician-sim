extends ColorRect


func _ready():
	color = Color.TRANSPARENT
	
func setup_signals():
	MainCommunicator.fadeIn.connect(fadeIn)
	
func fadeIn(fade_duration:float):
	var tween = create_tween()
	tween.tween_property(self, "color", Color.BLACK, fade_duration)
	await tween.finished
	MainCommunicator.fadeFinished.emit()

func fadeOut(fade_duration:float):
	var tween = create_tween()
	tween.tween_property(self, "color", Color.TRANSPARENT, fade_duration)
	await tween.finished
	MainCommunicator.fadeFinished.emit()
