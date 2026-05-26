extends Control

@export var anim_time:float = 0.5
@export var wait_time:float = 2.5

func _ready() -> void:
	var tween = create_tween()
	tween.tween_interval(wait_time)
	tween.tween_callback($Title.hide)
	tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	for child:Control in $Control.get_children():
		child.modulate = Color(1,1,1,0)
		child.show()
		tween.tween_property(child, "modulate", Color.WHITE, anim_time)
		tween.tween_interval(wait_time)
		tween.tween_property(child, "modulate", Color(1,1,1,0), anim_time)
	tween.tween_callback(get_tree().quit)
