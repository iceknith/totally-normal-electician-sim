class_name Duck extends Interactable3DDialogue

@export var num_anim:int = 8
@export var eow_meter_threshold:float = 0.75

@export var eow_meter:float = 0:
	set(new_val):
		eow_meter = new_val
		if eow_meter > eow_meter_threshold:
			animated_sprite_start_animation = "scared"

func _ready() -> void:
	animated_sprite_start_animation = "idle%d" % [randi_range(1,num_anim)]
	super()

func start_interaction():
	GlobalVars.ducks += 1
	var temp_title:String = title
	if GlobalVars.ducks == int(GlobalVars.max_ducks*1/4):
		temp_title = "quest_1/4"
	elif GlobalVars.ducks == int(GlobalVars.max_ducks/2):
		temp_title = "quest_1/2"
	if GlobalVars.ducks == int(GlobalVars.max_ducks*3/4):
		temp_title = "quest_3/4"
	elif GlobalVars.ducks >= GlobalVars.max_ducks:
		temp_title = "quest_end"
	MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.START_DIALOGUE, 
		[dialogue, temp_title, [self]] 
	)
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.ELEM_DELETED, self)
	queue_free.call_deferred()
