class_name Minigame extends Control


signal miniGameEnd

@export var music_when_entering:String = "Arcade"
@export var animationDuration:float = 0.4
@export var baseMinigameLayoutActive:bool = true
var base_minigame_layout = preload("res://src/minigames/base_minigame_layout.tscn")

var hasStarted:bool = false

func _ready() -> void:
	if baseMinigameLayoutActive: add_child(base_minigame_layout.instantiate())
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

func remove() -> void:
	# Disable process for all children
	for child in get_children(): child.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Define Tween
	var hide_tween:Tween = create_tween()
	hide_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	
	# Add properties
	hide_tween.tween_property(self, "scale", Vector2.ZERO, animationDuration)
	hide_tween.parallel().tween_property(self, "position", get_viewport_rect().size / 2, animationDuration)
	hide_tween.tween_callback(queue_free)
