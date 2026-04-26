class_name arcadePlayer extends CharacterBody2D

@onready var movementComponent = $Movement
@onready var HitBallComponent = $HitBall
@onready var AimComponent = $Aim

var input_direction:Vector2
var facing_direction:Vector2
var aiming_direction:Vector2


func _physics_process(delta):
	manage_input(delta)
	manage_variables()
	move_and_slide()
	set_facing_direction()
	
func manage_input(delta):
	input_direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	if HitBallComponent.launching_ball :
		manage_launching_ball(delta)
	else :
		aiming_direction = facing_direction
		velocity = movementComponent.calculate_velocity(velocity, input_direction)
		AimComponent.set_visibility(false)
	

	if Input.is_action_just_pressed("interract"):
		HitBallComponent.hit_ball()

func manage_variables():
	HitBallComponent.update_launching_ball_direction(aiming_direction)
	HitBallComponent.set_direction(facing_direction)
	
func set_facing_direction():
	if input_direction != Vector2.ZERO : 
		facing_direction = input_direction
	
func manage_launching_ball(delta):
	velocity = Vector2.ZERO
	AimComponent.set_visibility(true)
	aiming_direction = Vector2.from_angle(AimComponent.manage_aim(input_direction, delta))
	if Input.is_action_just_released("interract") : 
		HitBallComponent.release_ball()
