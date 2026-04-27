class_name MovementComponent extends Node2D


@export var speed = 10
@export var acceleration = 10



func calculate_velocity(velocity, direction:Vector2):
	var target_velocity = direction.normalized() * speed
	return velocity.lerp(target_velocity, 1.0 -exp(-20 * get_process_delta_time()))

func increase_move_speed(increase):
	speed += increase
	
func increase_acceleration(increase):
	acceleration += increase
	
func get_speed():
	return speed
	

func set_speed(v):
	speed = v
