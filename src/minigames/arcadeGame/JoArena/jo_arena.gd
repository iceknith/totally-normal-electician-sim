class_name JoArena extends Minigame

@onready var entities = $Entities
@onready var player = $Entities/Player

@onready var starting_position = $StartingPositions/PlayerStartingPosition

var shock_wave_scene:PackedScene = load("res://src/minigames/arcadeGame/effects/shock_wave.tscn")

@onready var shock_wave_container = $ShockWaveContainer
@onready var jo_attacks = $JoeAttacks
@onready var dialogue = load("res://src/minigames/arcadeGame/JoArena/JoDialogue/JoDialogue.dialogue")

@onready var animation_player = $JoBossFight

var last_loser:Node
var in_reset_animation:bool
var fight_progress = 0.0

enum BALLSTATE
{
	PlayerControl,
	EnemyControl,
	None
}





### Setup signals and plays fight Intro
func _ready() -> void:

	if GlobalVars.JoBeaten : 
		jo_beaten()
	else : 
		jo_attacks.fight_over.connect(end_fight)
		player.inform_death.connect(reset)
		await intro()
		start_game()


### Get all hitball component to connect the shockwave effect
func get_hitballs(node: Node):
	for child in node.get_children():
		if child is Hitball:
			return child
	return null
	




### start the game
func start_game():
	var offset = Vector2(0, 100)
	player.set_pause(true)
	player.set_pause(false)
	for ent in entities.get_children() : 
		var hitball:Hitball = get_hitballs(ent)
		if hitball !=null : 
			hitball.released_ball.connect(play_shockwave)
	jo_attacks.start_fight(jo_attacks.fight_id)
	
	
	
### Reset fights
func reset(p:arcadePlayer):
	jo_attacks.reset()
	await get_tree().create_timer(1.0).timeout
	player.global_position =  starting_position.global_position
	player.reset()
	jo_attacks.start_fight(jo_attacks.fight_id)

### Play the shockwave effect
func play_shockwave(entity):
	var shockwave:ShockWave = shock_wave_scene.instantiate()
	add_child(shockwave)
	shockwave.play_shockwave(entity)


### Function to exit minigame
func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)
	
### Plays the Intro Dialogue and starts the fight
func intro():
	SoundManager.change_music.emit("JoeIntro")
	
	MainCommunicator.send_signal_to_main(
	MainCommunicator.SignalType.START_DIALOGUE, 
	[dialogue, "_intro", [self]] 
	)
	await DialogueManager.dialogue_ended
	animation_player.play("teleport")
	await animation_player.animation_finished
	SoundManager.change_music.emit("Joe")
	await get_tree().create_timer(3).timeout
	
func end_fight():
	GlobalVars.JoBeaten = true
	MainCommunicator.send_signal_to_main(
	MainCommunicator.SignalType.START_DIALOGUE, 
	[dialogue, "_wonFight", [self]] 
	)


	await DialogueManager.dialogue_ended
	exit()
	
	
func jo_beaten():
	SoundManager.stop_music.emit()
	await get_tree().create_timer(2).timeout
	MainCommunicator.send_signal_to_main(
	MainCommunicator.SignalType.START_DIALOGUE, 
	[dialogue, "_joBeaten", [self]] 
	)
	await DialogueManager.dialogue_ended
	exit()
	
