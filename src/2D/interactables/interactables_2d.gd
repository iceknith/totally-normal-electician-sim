class_name Interactable2D extends Area2D


@export var interaction : Interaction
@export var dialogue:String = "res://src/Dialogue/dialogueTest/testDialogue.dialogue"

var was_viewed:bool = false
var is_viewed:bool = false
var is_interacted_with = true

@export var action_type:ActionType
@export var action:String = "interract"

enum ActionType
{
	Click,
	ActionPress,
}
enum Interaction {
	Nothing,
	Dialogue,
	Minigame
}

func full_interaction():
	start_interaction()

func _process(delta):
		
	if is_viewed && check_action() : 
		full_interaction()
		is_interacted_with = true
		
	was_viewed = is_viewed
	is_viewed = false
	
func start_interaction():
	match interaction : 
		Interaction.Dialogue : 
			MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.START_DIALOGUE, dialogue)
			
func check_action():
	match action_type:
		ActionType.ActionPress : 
			if Input.is_action_just_pressed(action) : 
				return true
	return false
		
			


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton : 
		if event.pressed and action_type == ActionType.Click : 
			print("clique")
			start_interaction()
