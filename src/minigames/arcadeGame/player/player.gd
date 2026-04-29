class_name arcadePlayer extends CharacterBody2D

@onready var movementComponent = $Movement
@onready var HitBallComponent = $HitBall
@onready var AimComponent = $Aim
@onready var DieComponent = $Die

var input_direction:Vector2
var facing_direction:Vector2
var aiming_direction:Vector2


@export var launch_counter:int = 0
@export var launch_speed:int = 200

var dead:bool = false
var paused:bool = false

func _ready():
	reset()
	setup_signals()

func _physics_process(delta):
	if !dead and !paused : 
		manage_input(delta)
		move_and_slide()
		set_facing_direction()
	manage_variables()
		
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
	aiming_direction = Vector2.from_angle(AimComponent.manage_aim(input_direction, delta))
	AimComponent.set_visibility(true)
	AimComponent.set_progress_bar_position(HitBallComponent.get_ball().global_position) #set the 
	launch_counter += delta*launch_speed
	AimComponent.set_progress_bar_value(launch_counter)
	if Input.is_action_just_released("interract") or launch_counter >= 99.9 : 
		HitBallComponent.release_ball()
		launch_counter = 0

func setup_signals():
	DieComponent.die.connect(death)
	
func death(entity):
	HitBallComponent.release_ball_on_death()
	DieComponent.turn_off()
	dead = true
	
func reset():
	DieComponent.turn_on()
	$Sprite2D.visible = true
	$DeathParticle.visible = false
	dead = false

func set_pause(v:bool):
	paused = v 
	
func disableDieComponent():
	DieComponent.can_die = false
