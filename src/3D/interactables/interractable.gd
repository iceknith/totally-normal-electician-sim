class_name Interractable extends Area3D

@export var function_on_interract:Callable = func(): print("hey")
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
@export var lock_camera_when_interact:bool = true


@export var dialogue:String = "res://src/Dialogue/dialogueTest/testDialogue.dialogue"
#Interaction Dialogue Parameters






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
		full_interaction()
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
	
func interaction_animation():
	match InteractionAnimation : 
		AnimationOnInteraction.TurnAndZoom: 
			PlayerCamera.turn_then_zoom(camera_root.global_position, turn_time, zoom_time, zoom_intensity)
		AnimationOnInteraction.TurnWhileZoom : 
			PlayerCamera.turn_while_zoom(camera_root.global_position, turn_time, zoom_time, zoom_intensity)
		AnimationOnInteraction.Turn : 
			PlayerCamera.turn_to_look_at(camera_root.global_position, turn_time)

func start_interaction():
	match interaction : 
		Interaction.Dialogue : 
			MainCommunicator.signalMain.emit(
			MainCommunicator.SignalType.CHANGE_GAMESTATE,\
			MainCommunicator.GameState.Dialogue)
			MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.START_DIALOGUE, dialogue)
			
func full_interaction():
	interaction_animation()
	print("1 : ")
	await interaction_animation()
	print("2 : ")
	start_interaction()

			
		
	
	
