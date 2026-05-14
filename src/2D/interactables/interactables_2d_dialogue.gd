class_name Interactable2DDialogue extends Interactable2D

@export var unique_name:String
@export var dialogue:DialogueResource
@export var title:String = "start":
	set(new_val):
		GlobalVars.dialogue_starts.set(unique_name, new_val)
	get():
		return GlobalVars.dialogue_starts.get(unique_name, title)
@export var close_up:AnimatedSprite2D
@export var close_up_start_animation:String:
	set(new_val):
		GlobalVars.dialogue_start_anim.set(unique_name, new_val)
		if close_up: close_up.play(new_val)
	get:
		return GlobalVars.dialogue_start_anim.get(unique_name)

func _ready() -> void:
	super()
	close_up.hide()

func start_interaction():
	MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.START_DIALOGUE, 
		[dialogue, title, [self]] 
	) # On lance le dialogue avec les options de dialogues associées
	hide()
	close_up.show()
	close_up.play(close_up_start_animation)
	DialogueManager.dialogue_ended.connect(end_interaction)

func end_interaction(_ressource):
	show()
	close_up.hide()
	close_up.stop()
	DialogueManager.dialogue_ended.disconnect(end_interaction)
