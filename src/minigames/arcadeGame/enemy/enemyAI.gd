class_name ArcadeEnemy extends CharacterBody2D


@onready var movementComponent = $Movement
@onready var HitBallComponent = $HitBall
@onready var AimComponent = $Aim
@onready var DieComponent = $Die

var facing_direction:Vector2
var aiming_direction:Vector2
var input_direction:Vector2
var launch_speed = 200
var launch_counter = 0

var dead:bool

func _ready():
	reset()
	
	
func _physics_process(delta):
	if !dead : 
		manage_input(delta)
		move_and_slide()
		set_facing_direction()
		manage_variables()
	else : 
		velocity = Vector2.ZERO
	
func manage_input(delta):
	if HitBallComponent.launching_ball :
		manage_launching_ball(delta)
	else :
		velocity = movementComponent.calculate_velocity(velocity, input_direction)
		AimComponent.set_visibility(false)
		
func manage_launching_ball(delta):
	velocity = Vector2.ZERO
	AimComponent.manage_aim(aiming_direction, delta)
	AimComponent.set_visibility(true)
	AimComponent.set_progress_bar_position(HitBallComponent.get_ball().global_position) #set the 
	launch_counter += delta*launch_speed
	AimComponent.set_progress_bar_value(launch_counter)
	if launch_counter >= 99.9 : 
		HitBallComponent.release_ball()
		launch_counter = 0
		
func set_facing_direction():
	if input_direction != Vector2.ZERO : 
		facing_direction = input_direction
		
func manage_variables():
	HitBallComponent.update_launching_ball_direction(aiming_direction)
	HitBallComponent.set_direction(facing_direction)
	
func set_input_direction(inp_dir:Vector2): #setter for input direction
	input_direction = inp_dir
	
func set_aiming_direction(aim_dir):
	aiming_direction = aim_dir
	
func get_sprite_size():
	var size = $Sprite2D.texture.get_size() * $Sprite2D.scale
	return size

func death(entity):
	HitBallComponent.release_ball_on_death()
	DieComponent.turn_off()
	dead = true
	
func reset():
	DieComponent.turn_on()
	$Sprite2D.visible = true
	$DeathParticle.visible = false
	dead = false
	

func setup_signals():
	DieComponent.die.connect(death)

	
