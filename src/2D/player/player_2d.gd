class_name player2D extends CharacterBody2D


@export var speed = 300
@export var acceleration = 20


var direction:Vector2

func _ready():
	pass

func _process(delta):
	manageInput(delta)

func manageInput(delta) -> void: #manage movements
	direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	velocity = lerp(velocity, direction * speed, acceleration*delta)
	move_and_slide()
