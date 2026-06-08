class_name ArcadeGame extends Minigame

@onready var entities = $Entities
@onready var ball = $Ball

@onready var player = $Entities/Player
@onready var opponent = $Entities/LittleJo
@onready var JoManagerComponent = $Entities/JoManager

@onready var ScoreLabel = $ScoreLabel
@onready var CountdownLabel = $CountdownLabel

@onready var PlayerStartingPosition = $StartingPositions/PlayerStartingPosition
@onready var EnemyStartingPosition = $StartingPositions/EnemyStartingPosition

var last_loser:Node
var in_reset_animation:bool
var in_tutorial:bool = false
var play_tutorial:bool = false


@onready var dialogue:DialogueResource = preload("res://src/Dialogue/Arcade/DialogueArcade.dialogue")
@onready var tutorialTarget = load("res://src/minigames/arcadeGame/tutorialArena/target.tscn")

enum BALLSTATE
{
	PlayerControl,
	EnemyControl,
	None
}
const opponent_name:Dictionary[JoManager.opponent, String] = {
	JoManager.opponent.LittleJo : "LittleJo",
	JoManager.opponent.Jolister : "JoLister",
	JoManager.opponent.BigJo : "BigJo"
}

var opponent_preset:JoManager.opponent = JoManager.opponent.LittleJo
var PlayerScore:int
var EnemyScore:int
@export var ScoreToWin:int = 3

var tutorial_destroyed_targets: int = 0
var tutorial_total_targets: int = 0


func _ready() -> void:
	$ShockWave.visible = false
	PlayerScore = 0
	EnemyScore = 0
	JoManagerComponent.jo_preset = opponent_preset
	if play_tutorial : 
		start_tutorial()
	else : 
		start_game()
	setup_signals()
	
func setup_signals(): 
	for ent in entities.get_children() : 
		var hitball:Hitball = get_hitballs(ent)
		var death:Die = get_die(ent)
		if hitball !=null :
			hitball.released_ball.connect(play_shockwave)
		if death !=null :
			death.die.connect(update_winner)
		
func get_hitballs(node: Node):
	for child in node.get_children():
		if child is Hitball:
			return child
	return null
	
func get_die(node: Node):
	for child in node.get_children():
		if child is Die:
			return child
	return null

func update_winner(dead_one):
	for ent in entities.get_children() : 
		var hitball:Hitball = get_hitballs(ent)
		if hitball !=null :
			hitball.release_ball()
	if !in_reset_animation :
		in_reset_animation = true
		last_loser = dead_one
		JoManagerComponent.set_pause_movement(true)
		if dead_one is arcadePlayer : 
			EnemyScore += 1
		else : 
			PlayerScore +=1
		await show_score()
		await get_tree().create_timer(2.0).timeout
		reset()
		await check_if_end_game()
		
		start_round()
		in_reset_animation = false

	
	
	
func show_score():
	$ScoreLabel.text = str(PlayerScore) + " - " + str(EnemyScore)

	
		
func reset():
	$ShockWave.visible = false
	player.global_position = Vector2(randi_range(200, 952), randf_range(100, 548))
	opponent.global_position = Vector2(randi_range(200, 952), randf_range(100, 548))
	ball.global_position = Vector2(1152/2, 648/2)
	player.reset()
	opponent.reset()
	ball.reset()

	

		
func play_death_shockwave(entity):
	var mat = $ShockWave.material as ShaderMaterial
	var center = entity.position / size
	mat.set_shader_parameter("center",center)
	
	$AnimationPlayer.play("shockwave")

	
func play_shockwave(entity):
	var mat = $ShockWave.material as ShaderMaterial
	var center = ball.position / size
	mat.set_shader_parameter("center",center)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("shockwave")
	

func start_game():
	var offset = Vector2(0, 100)
	ball.global_position = Vector2(1152/2, 648/2) + offset
	JoManagerComponent.set_pause_movement(true)
	player.set_pause(true)
	player.global_position = PlayerStartingPosition.global_position
	opponent.global_position = EnemyStartingPosition.global_position
	await CountdownLabel.start_countdown(3, 5)
	JoManagerComponent.set_pause_movement(false)
	player.set_pause(false)
	
	
func start_round():
	ball.global_position = Vector2(1152/2, 648/2)
	JoManagerComponent.set_pause_movement(true)
	player.set_pause(true)
	CountdownLabel.visible = true
	player.global_position = PlayerStartingPosition.global_position
	opponent.global_position = EnemyStartingPosition.global_position
	var spawn_offset = Vector2(200, 0)
	if last_loser is arcadePlayer : 
		ball.global_position = PlayerStartingPosition.global_position + spawn_offset
	else : 
		ball.global_position = EnemyStartingPosition.global_position - spawn_offset
	await CountdownLabel.start_countdown(3, 3)
	JoManagerComponent.set_pause_movement(false)
	player.set_pause(false)
	
func check_if_end_game():
	if PlayerScore == ScoreToWin : 
		opponent.visible = false
		opponent.process_mode = Node.PROCESS_MODE_DISABLED
		MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.START_DIALOGUE, 
		[dialogue,"Beaten" + opponent_name[opponent_preset], [self]])
		await DialogueManager.dialogue_ended
		exit()
			
	if EnemyScore == ScoreToWin : 
		player.visible = false
		player.process_mode = Node.PROCESS_MODE_DISABLED
		MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.START_DIALOGUE, 
		[dialogue, "Win"+opponent_name[opponent_preset], [self]] 
		)
		await DialogueManager.dialogue_ended
		exit()
	
func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)


func reset_game():
	PlayerScore = 0
	EnemyScore = 0
	reset()
	

func start_tutorial():
	in_tutorial = true
	opponent.visible = false
	opponent.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(2).timeout
	MainCommunicator.send_signal_to_main(
			MainCommunicator.SignalType.START_DIALOGUE, 
			[dialogue, "Tutorial1", [self]] 
			)
			
	await DialogueManager.dialogue_ended
	await get_tree().create_timer(4).timeout
	
	MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.START_DIALOGUE, 
		[dialogue, "Tutorial2", [self]] 
		)
	
	await DialogueManager.dialogue_ended
	
	while (ball.mouvement_component.get_speed() < 600) : 
		await get_tree().physics_frame
	await ball.scale_down_animation()
	ball.global_position = Vector2(1152/2, 648/2) 
	ball.reset()
	await ball.scale_up_animation()

	
	MainCommunicator.send_signal_to_main(
	MainCommunicator.SignalType.START_DIALOGUE, 
	[dialogue, "Tutorial3", [self]] 
	)


	await spawn_and_wait_tutorial_targets()

		
	MainCommunicator.send_signal_to_main(
	MainCommunicator.SignalType.START_DIALOGUE, 
	[dialogue, "Tutorial4", [self]] 
	)
	
	await DialogueManager.dialogue_ended
	opponent.visible = true
	opponent.process_mode = Node.PROCESS_MODE_INHERIT
	reset_game()
	start_game()
	
	
	
	
	
func spawn_and_wait_tutorial_targets():
	var target_positions = [
		Vector2(200, 250),
		Vector2(950, 250),
		Vector2(200, 500),
		Vector2(950, 500)
	]
	
	tutorial_destroyed_targets = 0
	tutorial_total_targets = target_positions.size()
	
	for pos in target_positions:
		var target_instance = tutorialTarget.instantiate()
		entities.add_child(target_instance)
		target_instance.global_position = pos
		
		target_instance.target_destroyed.connect(_on_tutorial_target_destroyed)
	
	while tutorial_destroyed_targets < tutorial_total_targets :
		await get_tree().process_frame


func _on_tutorial_target_destroyed():
	tutorial_destroyed_targets += 1

	
	
	
