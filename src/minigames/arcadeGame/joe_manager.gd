class_name JoManager
extends Node2D

@export var attack_cooldown: float = 3
@export var enemy: ArcadeEnemy
@onready var player: arcadePlayer = $"../Player"
@onready var ball: arcade_ball = $"../../Ball"
@export var distance_to_hit = 100
@export var distance_max_to_ball = 75
var pause_movement: bool
var dir_to_ball: Vector2
@export var JoCatchRate: Curve
@export var max_manageable_speed: int = 500
signal has_rolled_probabilities
var rolled_probabilities: bool = false

enum opponent {
	LittleJo,
	BigJo
}

func _ready():
	has_rolled_probabilities.connect(reset_roll)

func _process(delta):
	if !pause_movement:
		manage_jo_input(delta)
	else:
		enemy.velocity = Vector2.ZERO
		enemy.set_input_direction(Vector2.ZERO)

func manage_jo_input(delta):
	dir_to_ball = ball.global_position - enemy.global_position
	
	if player.HitBallComponent.launching_ball:
		movement_when_player_launching()
	else:
		movement_when_player_not_launching()

	if dir_to_ball.length() < distance_to_hit:
		var launch_probability = 0.0
		
		if !rolled_probabilities:
			launch_probability = clamp(
				JoCatchRate.sample(ball.mouvement_component.get_speed() / max_manageable_speed),
				0.0, 1.0
			)
			rolled_probabilities = true
			has_rolled_probabilities.emit()
		
		var succes_probability = randf()
		
		if succes_probability <= launch_probability:
			set_launch_direction()
			print("sp : ", succes_probability, "lp : ", launch_probability )
			enemy.HitBallComponent.hit_ball()
	


func set_pause_movement(v: bool):
	pause_movement = v

func movement_when_player_not_launching():
	var dir_to_move = dir_to_ball.normalized()
	
	if dir_to_ball.length() > distance_max_to_ball:
		enemy.set_input_direction(dir_to_move)
	else:
		enemy.set_input_direction(Vector2.ZERO)

func movement_when_player_launching():
	var dir_to_move = enemy.global_position - player.global_position
	var direction = dir_to_move.normalized()
	
	direction.x = sign(direction.x)
	direction.y = sign(direction.y)
	
	if dir_to_ball.length() > distance_max_to_ball:
		enemy.set_input_direction(direction)
	else:
		enemy.set_input_direction(Vector2.ZERO)

func set_launch_direction():
	if randi() % 3 == 0:
		var randomDirection = Vector2([-1, 1].pick_random(), [-1, 1].pick_random())
		enemy.set_aiming_direction(randomDirection)
	else:
		var launchDirection = (player.global_position - enemy.global_position).normalized()
		enemy.set_aiming_direction(launchDirection)

func reset_roll():
	await get_tree().create_timer(0.2).timeout
	rolled_probabilities = false
