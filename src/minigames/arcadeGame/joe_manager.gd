class_name JoManager extends Node2D


@export var attack_cooldown:float = 3

@export var enemy:ArcadeEnemy
@onready var player:arcadePlayer = $"../Player"
@onready var ball:arcade_ball = $"../../Ball"

@export var distance_to_hit = 200
@export var distance_max_to_ball = 150

var pause_movement:bool
var dir_to_ball:Vector2


enum opponent 
{
	LittleJo,
	BigJo
}

func _process(delta):
	if !pause_movement : 
		manage_jo_input(delta)
	else : 
		enemy.velocity = Vector2.ZERO
	
	
	
func manage_jo_input(delta):
	
	dir_to_ball =  ball.global_position - enemy.global_position
	if !player.HitBallComponent.launching_ball :  
		movement_when_player_not_launching()
	else : 
		movement_when_player_launching()
		
	if dir_to_ball.length() < distance_to_hit : 
		set_launch_direction()
		enemy.HitBallComponent.hit_ball()
		
	
	

func set_pause_movement(v:bool):
	pause_movement = v
	
func movement_when_player_not_launching(): #when player is not launching we try to get closer to the ball
	var dir_to_move = dir_to_ball.normalized()
	dir_to_move.x = sign(dir_to_move.x)
	dir_to_move.y = sign(dir_to_move.y)
	if (dir_to_ball.length() > distance_max_to_ball):
		enemy.set_input_direction(dir_to_move)
	else :
		enemy.set_input_direction(Vector2.ZERO)
	
	



func movement_when_player_launching(): #when player is launching we try to get away
	var dir_to_move =  enemy.global_position - player.global_position
	var direction = dir_to_move.normalized()
	direction.x = sign(direction.x)
	direction.y = sign(direction.y)
	if (dir_to_ball.length() > distance_max_to_ball):
		enemy.set_input_direction(direction)
	else :
		enemy.set_input_direction(Vector2.ZERO)
	
	
func set_launch_direction():
	if randi() % 3 == 0:
		var randomDirection = Vector2([-1, 1].pick_random(), [-1, 1].pick_random())
		enemy.set_aiming_direction(randomDirection)
	else:
		var launchDirection = (player.global_position - enemy.global_position).normalized()
		enemy.set_aiming_direction(launchDirection)
