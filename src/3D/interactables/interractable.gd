class_name Interractable extends Area3D

@export var function_on_interract:Callable = func(): pass
@export var action:String = "interract"


enum AnimationOnInteraction {
	TurnAndZoom,
	Turn,
	TurnWhileZoom,
	Nothing
}

enum Interaction {
	Nothing,
	Dialogue,
	Minigame
}
@export var InteractionAnimation :AnimationOnInteraction
@export var interaction : Interaction

#Camera Interaction Parameters
@export var camera_root:Node3D # the point the camera will turn to
@export var turn_time:float = 0.5
@export var zoom_time:float = 0.5
@export var zoom_intensity:float = 10

@export_file("*.dialogue", ) var dialogue:String
@export var title:String = "start"
#Interaction Dialogue Parameters

@onready var text_sprite:Sprite3D = $Sprite3D
@onready var text_label:Label = $SubViewport/PanelContainer/MarginContainer/Label

var was_viewed:bool = false
var is_viewed:bool = false:
	set(new_val):
		viewed_handler(new_val)
		is_viewed = new_val
var is_viewed_false_timer:SceneTreeTimer

var is_interacted_with:bool = false

func _ready() -> void:
	set_key_text()
	text_sprite.hide()

func set_key_text() -> void:
	pass

func _process(delta: float) -> void:
	# Listen for inputs if visible
	if is_viewed && Input.is_action_just_pressed(action):
		function_on_interract.call()
		full_interaction()
		is_interacted_with = true

func viewed_handler(new_val):
	if new_val:
		if is_viewed:
			is_viewed_false_timer.time_left = 0.1
		else:
			show_text()
			is_viewed_false_timer = get_tree().create_timer(0.1)
			is_viewed_false_timer.timeout.connect(func(): is_viewed=false)
			is_viewed_false_timer.timeout.connect(hide_text)

func player_viewing() -> void:
	is_viewed = true
	if !was_viewed: show_text()

func show_text():
	text_sprite.show()

func hide_text():
	text_sprite.hide()

func interaction_animation():
	match InteractionAnimation : 
		AnimationOnInteraction.TurnAndZoom: 
			MainCommunicator.signalCamera.emit("turn_then_zoom", [camera_root.global_position, turn_time, zoom_time, zoom_intensity])
		AnimationOnInteraction.TurnWhileZoom : 
			MainCommunicator.signalCamera.emit("turn_then_zoom", [camera_root.global_position, turn_time, zoom_time, zoom_intensity])
		AnimationOnInteraction.Turn : 
			MainCommunicator.signalCamera.emit("turn_to_look_at", [camera_root.global_position, turn_time])

func start_interaction():
	match interaction : 
		Interaction.Dialogue : 
			MainCommunicator.send_signal_to_main(
				MainCommunicator.SignalType.START_DIALOGUE, [dialogue, title, [self]]
				)

func full_interaction():
	interaction_animation()
	start_interaction()
