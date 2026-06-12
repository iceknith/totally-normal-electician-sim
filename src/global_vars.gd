extends Node

###############
### General ###
###############

var eow_meter:float
var eow_max_time_s:float
var mouse_sentitivity:float = 0.006

##############
### Towers ###
##############

var electrician_minigame_current_stage:ElectricianMinigame.Stages = ElectricianMinigame.Stages.TutorialWires
signal tower_completed_value_change
signal all_tower_completed
var tower_completed:int = 0:
	set(new_val):
		tower_completed = new_val
		tower_completed_value_change.emit()
		if tower_amount == tower_completed : 
			all_tower_completed.emit()
var tower_amount:int = 0

######################
### Final Cutscene ###
######################

signal playFinalCutscene
var eow_music_trigger:float = 0


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


##############
### Arcade ###
##############

var LittleJoBeaten:bool = false
var JoListerBeaten:bool = false
var BigJoBeaten:bool = false
var JoBeaten:bool = false


##############
### RPS ###
##############

var tutorial_done:bool = false 
var first_interaction_willy = true
var willy_beaten = false
var stanly_beaten = false
var billy_won_game:bool = false
var billy_beaten = false

#############
### World ###
#############


var has_cake:bool = false
var bought_cake_superette:bool = false
var visited_superette:bool = false
var bought_cake_bakery:bool = false
var visited_bakery:bool = false

var mathew_algebra_has_failed:bool = false
var mathew_algebra_visited:bool = false
var mathew_algebra_finished:bool = false

var vera_visited:bool = false
var vera_told_secrets:bool = false

var tic_visited:bool = false
var tac_visited:bool = false

var bibi_visited:bool = false

var dialogue_counter_maryjolene = 0

var post_visits:int = 0
var max_post_visits:int = 5

var ducks:int = 0
var max_ducks:int = 0

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
