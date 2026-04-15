class_name MovementComponent extends Node2D


@export var speed = 10
@export var acceleration = 10



func calculate_velocity(velocity, direction:Vector2):
	var directionX:float = Input.get_axis("ui_left", "ui_right")
	var directionY:float = Input.get_axis("ui_up", "ui_down")
	var target_velocity = direction.normalized() * speed
	return velocity.lerp(target_velocity, 1.0 -exp(-20 * get_process_delta_time()))
