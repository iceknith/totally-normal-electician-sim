class_name Hitball extends Area2D


@export var cooldown:float

var launching_ball:bool
var launching_ball_direction:Vector2
var direction:Vector2
var ball:arcade_ball

signal caught_ball(entity)
signal released_ball(entity)



@onready var animation_player:AnimationPlayer = $AnimationPlayer
@export var base_time_before_launch:float

var attacking:bool

func hit_ball():
	if !attacking : 
		manage_rotation()
		attacking = true
		animation_player.play("Hit")
		await animation_player.animation_finished
		attacking = false
	
	

			
func manage_ball()->void:
	ball.stop()


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
	manage_rotation()
	
func launch():
	pass
			
func release_ball():
	released_ball.emit(get_parent().global_position)
	ball.update_direction(launching_ball_direction)
	launching_ball = false
	ball.set_moving(true)
	ball = null
	
func _on_body_entered(body):
	if attacking and body is arcade_ball: 
		caught_ball.emit(get_parent().global_position)
		launching_ball = true
		ball = body
		attacking = false
		manage_ball()
