extends Tower

@export var player:Player = null

func _ready() -> void:
	super()
	setup_signals()
	
	

func setup_signals():
	$FinalMinigame.connections["win"] = on_tower_completed
	GlobalVars.all_tower_completed.connect(final_cinematic_mode)

func final_cinematic_mode():
	pass
	
func switch_to_ladder():
	$tourechelle.visible = true
	$tour.queue_free()
	$echelle.queue_free()
	$echelle2.queue_free()
	

func deleteFinalMinigame():
	$FinalMinigame.queue_free()
