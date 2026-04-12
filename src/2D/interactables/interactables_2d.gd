@abstract class_name Interactable2D extends Area2D

var is_interacted_with:bool = true
var is_currently_interractable:bool = false

@export var action_type:ActionType
@export var action:String = "interract"
@export var interractable_dialogue:Node
var interractable_label:Label

enum ActionType
{
	Click,
	ActionPress,
}
#enum Interaction {
#	Nothing,
#	Dialogue,
#	Minigame
#}

@abstract func start_interaction()

func _ready() -> void:
	if interractable_dialogue == null: push_error("Interractable dialogue should be set !")
	interractable_label = find_label(interractable_dialogue)
	if interractable_label == null: push_error("Interractable dialogue should have a label !")
	
	match action_type:
		ActionType.Click:
			interractable_label.text = "Click"
			mouse_entered.connect(show_interactable_text)
			mouse_exited.connect(hide_interactable_text)
			input_event.connect(_on_input_event)
		ActionType.ActionPress:
			interractable_label.text = "E"
			body_entered.connect(_on_body_entered)
			body_exited.connect(_on_body_exited)
	interractable_dialogue.hide()

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
	if action_type == ActionType.ActionPress &&\
	 	is_currently_interractable && Input.is_action_just_pressed(action):
		start_interaction()

func _on_body_entered(body:Node2D):
	if body as Player2D:
		show_interactable_text()

func _on_body_exited(body:Node2D):
	if body as Player2D:
		hide_interactable_text()

func show_interactable_text():
	is_currently_interractable = true
	interractable_dialogue.show()

func hide_interactable_text():
	is_currently_interractable = false
	interractable_dialogue.hide()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton : 
		if event.pressed and action_type == ActionType.Click : 
			start_interaction()
