class_name JoArena extends Minigame

@onready var entities = $Entities
@onready var player = $Entities/Player


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
	$ShockWave.visible = false
	PlayerScore = 0
	EnemyScore = 0
	start_game()
		
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

	
	
	
func show_score():
	$ScoreLabel.text = str(PlayerScore) + " - " + str(EnemyScore)

	

		
func play_death_shockwave(entity):
	var mat = $ShockWave.material as ShaderMaterial
	var center = entity.position / size
	mat.set_shader_parameter("center",center)
	$AnimationPlayer.play("shockwave")


	

func start_game():
	var offset = Vector2(0, 100)
	player.set_pause(true)
	player.set_pause(false)
	
	
	
func check_if_end_game():
	if PlayerScore == ScoreToWin : 
		exit()
	if EnemyScore == ScoreToWin : 
		exit()
	
func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)
