class_name Interractable extends Area3D

@export var function_on_interract:Callable = func(): print("hey")
@export var action:String = "interract"


enum AnimationOnInteraction {
	TurnAndZoom,
	Turn,
	TurnWhileZoom,
	Nothing
}

@export var InteractionAnimation :AnimationOnInteraction


#Interaction Parameters
@export var camera_root:Node3D # the point the camera will turn to
@export var turn_to_when_interacting:bool
@export var turn_time:float = 0.5
@export var zoom_time:float = 0.5
@export var zoom_intensity:float = 0.2
@export var lock_camera_when_interact:bool = true




@onready var text_sprite:Sprite3D = $Sprite3D
@onready var text_label:Label = $SubViewport/PanelContainer/MarginContainer/Label


var PlayerCamera:Camera3D

var was_viewed:bool = false
var is_viewed:bool = false


var is_interacted_with:bool = false

func _ready() -> void:
	set_key_text()
	text_sprite.hide()

func set_key_text() -> void:
	pass

func _process(delta: float) -> void:
	# Hide text if no longer visible
	if !is_viewed && was_viewed:
		hide_text()
	
	# Listen for inputs if visible
		
	if is_viewed && Input.is_action_just_pressed(action):
		function_on_interract.call()
		start_interaction()
		is_interacted_with = true
	
# Reset visibility
	was_viewed = is_viewed
	is_viewed = false

func player_viewing() -> void:
	is_viewed = true
	if !was_viewed: show_text()

func show_text():
	text_sprite.show()

func hide_text():
	text_sprite.hide()
	
	
func get_player_camera(PlayerCam:Camera3D):
	PlayerCamera = PlayerCam
	
func start_interaction():
	if lock_camera_when_interact : #if options check locks camera movement when interacting with gameObject
		MainCommunicator.lock_camera = true
	match InteractionAnimation : 
		AnimationOnInteraction.TurnAndZoom: 
			PlayerCamera.turn_then_zoom(global_position, turn_time, zoom_time, zoom_intensity)
		AnimationOnInteraction.TurnWhileZoom : 
			PlayerCamera.turn_while_zoom(global_position, turn_time, zoom_time, zoom_intensity)
	
	
