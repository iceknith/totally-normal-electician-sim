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


enum BALLSTATE
{
	PlayerControl,
	EnemyControl,
	None
}

var PlayerScore:int
var EnemyScore:int


func _ready() -> void:
	$ShockWave.visible = false
	PlayerScore = 0
	EnemyScore = 0
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
	last_loser = dead_one
	JoManagerComponent.set_pause_movement(true)
	if dead_one is arcadePlayer : 
		EnemyScore += 1
	else : 
		PlayerScore +=1
	await show_score()
	await get_tree().create_timer(2.0).timeout
	reset()
	start_round()
	
	
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
	await $AnimationPlayer.animation_finished 
	$ShockWave.visible = false
	
func play_shockwave(entity):
	var mat = $ShockWave.material as ShaderMaterial
	var center = ball.position / size
	mat.set_shader_parameter("center",center)
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
