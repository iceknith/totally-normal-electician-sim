class_name arcadePlayer extends CharacterBody2D

@onready var movementComponent = $Movement


func _physics_process(delta):
	manage_input()
	move_and_slide()
	
func manage_input():
	var direction:Vector2 = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	velocity = movementComponent.calculate_velocity(velocity, direction)
	
