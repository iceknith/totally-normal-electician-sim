extends Node

##############
### Towers ###
##############

var electrician_minigame_current_stage:ElectricianMinigame.Stages = ElectricianMinigame.Stages.FullGame
signal tower_completed_value_change
var tower_completed:int = 0:
	set(new_val):
		tower_completed = new_val
		tower_completed_value_change.emit()
var tower_amount:int = 0

#############
### Money ###
#############

var money:int = 0
