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
	if GlobalVars.ducks >= GlobalVars.max_ducks:
		title = "quest_end"
	super()
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.ELEM_DELETED, self)
	queue_free.call_deferred()
