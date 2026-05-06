class_name JoArena extends Minigame

@onready var entities = $Entities
@onready var player = $Entities/Player

@onready var starting_position = $StartingPositions/PlayerStartingPosition

var shock_wave_scene:PackedScene = load("res://src/minigames/arcadeGame/effects/shock_wave.tscn")

@onready var shock_wave_container = $ShockWaveContainer
@onready var jo_attacks = $JoeAttacks

var last_loser:Node
var in_reset_animation:bool

enum BALLSTATE
{
	PlayerControl,
	EnemyControl,
	None
}

var PlayerScore:int
var EnemyScore:int
@export var ScoreToWin:int = 3


func _ready() -> void:
	PlayerScore = 0
	EnemyScore = 0
	start_game()
	player.inform_death.connect(reset)
		
func get_hitballs(node: Node):
	for child in node.get_children():
		if child is Hitball:
			return child
	return null
	

	
func show_score():
	$ScoreLabel.text = str(PlayerScore) + " - " + str(EnemyScore)


func start_game():
	var offset = Vector2(0, 100)
	player.set_pause(true)
	player.set_pause(false)
	for ent in entities.get_children() : 
		var hitball:Hitball = get_hitballs(ent)
		if hitball !=null : 
			hitball.released_ball.connect(play_shockwave)
	jo_attacks.start_fight()
	
	
	
func reset(p:arcadePlayer):
	jo_attacks.reset()
	await get_tree().create_timer(1.0).timeout
	player.global_position =  starting_position.global_position
	player.reset()
	jo_attacks.start_fight()

func play_shockwave(entity):
	var shockwave:ShockWave = shock_wave_scene.instantiate()
	add_child(shockwave)
	shockwave.play_shockwave(entity)

func check_if_end_game():
	if PlayerScore == ScoreToWin : 
		exit()
	if EnemyScore == ScoreToWin : 
		exit()
	
func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)
