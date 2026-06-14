extends Tower

@export var player:Player = null

func _ready() -> void:
	super()
	setup_signals()
	$tourechelle/Echelle.visible = false

func setup_signals():
	$FinalMinigame.connections["win"] = on_second_tower_completed
	GlobalVars.all_tower_completed.connect(final_cinematic_mode)

func on_second_tower_completed():
	$FinalMinigame.queue_free()
	$AlarmTop2.light_energy = 0

func final_cinematic_mode():
	pass
	
func switch_to_ladder():
	$tourechelle/Echelle.visible = true
	$echelle.queue_free()
	$echelle2.queue_free()
	

func deleteFinalMinigame():
	$FinalMinigame.queue_free()
