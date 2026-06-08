extends Control

@export var wait_time:float = 5
@export var transition_duration:float = 1

func _ready() -> void:
	var tween:Tween = create_tween()
	tween.tween_interval(wait_time)
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_callback(SoundManager.change_music.emit.bind("MainTheme"))
	tween.tween_property(self, "modulate", Color(1,1,1,0), transition_duration)
	tween.tween_callback(queue_free)
