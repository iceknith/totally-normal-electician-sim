class_name Hitball extends Area2D



var launching_ball:bool
var launching_ball_direction:Vector2

var can_hit:bool
@export var hit_cooldown:float = 1

var direction:Vector2
var ball:arcade_ball

@export var ball_color:Color

signal caught_ball(entity)
signal released_ball(entity)



@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var cooldown_timer:Timer = $Timer
@export var base_time_before_launch:float

var attacking:bool
@export var ball_state_to_give:ArcadeGame.BALLSTATE

func _ready():
	can_hit = true
	cooldown_timer.wait_time = hit_cooldown

func hit_ball():
	if !attacking and can_hit: 
		manage_rotation()
		can_hit = false
		cooldown_timer.start()
		attacking = true
		animation_player.play("Hit")
		await animation_player.animation_finished
		attacking = false
		
func manage_ball()->void:
	ball.stop()
	ball.update_ball_color(ball_color)
	
	ball.update_ball_state(ball_state_to_give)
	ball.set_being_launched(true)


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
			
func release_ball():
	released_ball.emit(get_parent())
	ball.update_direction(launching_ball_direction)
	launching_ball = false
	ball.set_moving(true)
	ball.set_being_launched(false)
	ball = null
	
func release_ball_on_death(): 
	if ball !=null : 
		ball.update_direction(Vector2.ZERO)
		launching_ball = false
		ball.set_moving(false)
		ball.set_being_launched(false)
		ball = null
	
	
func _on_body_entered(body):
	if attacking and body is arcade_ball: 
		if body.being_launched == false : 
			caught_ball.emit(get_parent())
			launching_ball = true
			ball = body
			attacking = false
			manage_ball()

func get_ball():
	return ball


func _on_timer_timeout():
	can_hit = true
