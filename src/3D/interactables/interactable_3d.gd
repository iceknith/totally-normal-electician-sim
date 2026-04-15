@abstract class_name Interactable3D extends Area3D

@export var action:String = "interract"

enum AnimationOnInteraction {
	Nothing,
	TurnAndZoom,
	Turn,
	TurnWhileZoom,
}

@export var text_sprite:Sprite3D
var text_label:Label
@export var InteractionAnimation:AnimationOnInteraction = AnimationOnInteraction.Nothing
@export_group("Animation")
@export var camera_root:Node3D # the point the camera will turn to
@export var turn_time:float = 0.5
@export var zoom_time:float = 0.5
@export var zoom_intensity:float = 10


var was_viewed:bool = false
var is_viewed:bool = false:
	set(new_val):
		viewed_handler(new_val)
		is_viewed = new_val
var is_viewed_false_timer:SceneTreeTimer

var is_interacted_with:bool = false

func _ready() -> void:
	collision_layer = 0b100
	collision_mask = 0b0
	text_label = find_label(text_sprite)
	text_sprite.hide()

func find_label(node:Node) -> Label:
	"""
	Explore recursivly node to find label
	"""
	if node != null:
		for child in node.get_children():
			if child as Label: return child
			else: 
				var label = find_label(child)
				if label:
					return label
	return null

func _process(_delta: float) -> void:
	# Listen for inputs if visible
	if is_viewed && Input.is_action_just_pressed(action):
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

@abstract func start_interaction()

func full_interaction():
	interaction_animation()
	start_interaction()
