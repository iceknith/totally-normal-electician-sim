class_name Minigame extends Control

signal miniGameEnd

@export var animationDuration:float = 0.4

var hasStarted:bool = false

func _ready() -> void:
	show_animation()

func show_animation() -> void:
	# Set init vals
	scale = Vector2.ZERO
	position = get_viewport_rect().size / 2
	
	# Define Tween
	var show_tween:Tween = create_tween()
	show_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	# Add properties
	show_tween.tween_property(self, "scale", Vector2.ONE, animationDuration)
	show_tween.parallel().tween_property(self, "position", Vector2.ZERO, animationDuration)
	show_tween.tween_property(self, "hasStarted", true, animationDuration/5)
