class_name Hitball extends Area2D


@export var cooldown:float

var launching_ball:bool
var launching_ball_direction:Vector2
var direction:Vector2

@onready var animation_player:AnimationPlayer = $AnimationPlayer

@export var base_time_before_launch:float


func hit_ball():
	manage_rotation()
	animation_player.play("Hit")
	for body in get_overlapping_bodies() :
		if body is arcade_ball : 
			manage_ball(body)
			
func manage_ball(ball:arcade_ball)->void:
	ball.stop()
	ball.update_direction(launching_ball_direction)
	ball.set_moving(true)

func update_launching_ball_direction(dir:Vector2)-> void:
	launching_ball_direction = dir
	
func manage_rotation():
	if direction == Vector2.ZERO : 
		return
	var angle = direction.angle() 
	rotation = angle
	
	
func set_direction(dir):
	direction = dir

func _physics_process(delta):
	pass
	
func launch():
	pass
			
