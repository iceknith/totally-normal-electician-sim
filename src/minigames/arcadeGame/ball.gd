class_name arcade_ball extends CharacterBody2D


@onready var mouvement_component:MovementComponent = $MovementComponent

var current_direction:Vector2
var moving:bool
var old_velocity:Vector2 = Vector2.ZERO

var current_shot:int = 0


func stop():
	moving = false
	mouvement_component.increase_move_speed(40)
	

	
func update_velocity():
	pass
	
func _physics_process(delta):
	manage_speed()

	
	manage_scale()
	store_velocity()
	if moving : 
		move_and_slide()
		manage_direction()
		store_velocity()


	
	
func manage_speed():
	velocity = mouvement_component.calculate_velocity(velocity, current_direction)
	
func update_direction(d:Vector2):
	current_direction = d

func manage_direction():
	if is_on_wall() : 
		current_direction.x = - current_direction.x
	if is_on_ceiling() : 
		current_direction.y = - current_direction.y
	if is_on_floor() : 
		current_direction.y = - current_direction.y
		
func manage_scale():
	var speed = old_velocity.length()

	rotation = velocity.angle()

	var speed_ratio = clamp(speed / 800.0, 0.0, 8)

	var base_scale = lerp(1.0, 1.6, speed_ratio)


	var max_stretch = lerp(0.1, 0.6, speed_ratio) * 0
	var stretch = speed_ratio * max_stretch * 0

	scale.x = base_scale * (1.0 + stretch)
	scale.y = max(base_scale * (1.0 - stretch * 0.5), base_scale)

		
	#to do, établir des min_scales pour que la balle se déforme correctement, aussi mettre des tween et rajouter des particules
		
		
func manage_rotation():
	if velocity != Vector2.ZERO:
		rotation = velocity.angle()

func set_moving(v:bool):
	moving = v
	
func store_velocity():
	if velocity != Vector2.ZERO and velocity > old_velocity: 
		old_velocity = velocity
