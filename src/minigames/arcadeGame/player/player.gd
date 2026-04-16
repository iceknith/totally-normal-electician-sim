class_name arcadePlayer extends CharacterBody2D

@onready var movementComponent = $Movement
@onready var HitBallComponent = $HitBall

var input_direction:Vector2
var facing_direction:Vector2

func _physics_process(delta):
	manage_input()
	manage_variables()
	move_and_slide()
	set_facing_direction()
	
func manage_input():
	input_direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	velocity = movementComponent.calculate_velocity(velocity, input_direction)
	
	if Input.is_action_just_pressed("interract"):
		HitBallComponent.hit_ball()

func manage_variables():
	HitBallComponent.update_launching_ball_direction(facing_direction)
	HitBallComponent.set_direction(facing_direction)
	
func set_facing_direction():
	if input_direction != Vector2.ZERO : 
		facing_direction = input_direction
	
