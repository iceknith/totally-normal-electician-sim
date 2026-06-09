extends Tower

@export var player:Player = null

func _ready() -> void:
	$FinalInterractable.monitoring = false
	setup_signals()
	
func _physics_process(delta):
	pass
	

func setup_signals():
	GlobalVars.all_tower_completed.connect(final_cinematic_mode)

func final_cinematic_mode():
	$FinalInterractable.monitoring = true
	
