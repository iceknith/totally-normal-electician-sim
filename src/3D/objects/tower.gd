class_name Tower extends Node3D

func _ready() -> void:
	$Interractable.connections["win"] = on_tower_completed
	$Interractable._ready()

func on_tower_completed() -> void:
	$AnimationPlayer.play("RESET")
	$Interractable.queue_free()
	GlobalVars.tower_completed += 1
	if GlobalVars.electrician_minigame_current_stage != ElectricianMinigame.Stages.FullGame:
		GlobalVars.electrician_minigame_current_stage += 1
