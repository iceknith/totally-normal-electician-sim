class_name Interactable2DDialogue extends Interactable2D

@export_file("*.dialogue", ) var dialogue:String
@export var title:String = "start"
@export var close_up:AnimatedSprite2D
@export var close_up_animation:String:
	set(new_val):
		close_up_animation = new_val
		if close_up: close_up.play(new_val)

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
	close_up.play(close_up_animation)
	DialogueManager.dialogue_ended.connect(end_interaction)

func end_interaction(_ressource):
	show()
	close_up.hide()
	close_up.stop()
	DialogueManager.dialogue_ended.disconnect(end_interaction)
