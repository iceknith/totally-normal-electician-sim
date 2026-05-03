extends Node

###############
### General ###
###############

var eow_meter:float

##############
### Towers ###
##############

var electrician_minigame_current_stage:ElectricianMinigame.Stages = ElectricianMinigame.Stages.TutorialWires
signal tower_completed_value_change
var tower_completed:int = 0:
	set(new_val):
		tower_completed = new_val
		tower_completed_value_change.emit()
var tower_amount:int = 0

################
### Dialogue ###
################

var dialogue_starts:Dictionary[String, String] = {}
var dialogue_start_anim:Dictionary[String, String] = {}

func get_current_title(title:String, dialogue:DialogueResource) -> String:
	var current_title = title
	var current_closest_val:float = 0
	
	for dialogueTitle in dialogue.get_titles():
		if title in dialogueTitle:
			var value = dialogueTitle.replace(title, "").to_float()/100
			if value <= eow_meter && value >= current_closest_val:
				current_title = dialogueTitle
				current_closest_val = value
		if "global" in dialogueTitle:
			var value = dialogueTitle.replace("global", "").to_float()/100
			if value <= eow_meter && value > current_closest_val:
				current_title = dialogueTitle
				current_closest_val = value
	
	return current_title

#############
### World ###
#############

var has_cake:bool = false
var has_decorations:bool = false

################
### Controls ###
################

signal action_changed(action_name:String)
func get_action_controls(action_name:String) -> String:
	var key_text = "-"
	if InputMap.has_action(action_name):
		for action in InputMap.action_get_events(action_name):
			if action as InputEventKey:
				var label = DisplayServer.keyboard_get_label_from_physical(action.physical_keycode)
				key_text = OS.get_keycode_string(label)
	return key_text
