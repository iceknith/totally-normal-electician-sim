class_name Interactable3DDialogue extends Interactable3D

@export var unique_name:String
@export var dialogue:DialogueResource
@export var title:String = "start":
	set(new_val):
		GlobalVars.dialogue_starts.set(unique_name, new_val)
	get():
		return GlobalVars.dialogue_starts.get(unique_name, title)
@export var animated_sprite:AnimatedSprite3D
@export var animated_sprite_start_animation:String:
	set(new_val):
		GlobalVars.dialogue_start_anim.set(unique_name, new_val)
		if animated_sprite: animated_sprite.play(new_val)
	get:
		return GlobalVars.dialogue_start_anim.get(unique_name)

func _ready() -> void:
	super()
	animated_sprite.play(animated_sprite_start_animation)

func start_interaction():
	var current_title = GlobalVars.get_current_title(title, dialogue)
	
	MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.START_DIALOGUE, 
		[dialogue, current_title, [self]] 
	) # On lance le dialogue avec les options de dialogues associées
	animated_sprite.play(animated_sprite_start_animation)
