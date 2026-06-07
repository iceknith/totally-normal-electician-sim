class_name Player2D extends CharacterBody2D


@export var speed = 300
@export var acceleration = 50


var direction:Vector2

func _ready():
	collision_mask = 0
	collision_layer = 0
	await  get_tree().create_timer(1).timeout
	collision_mask = 1
	collision_layer = 1
	

func _process(delta):
	if !MainCommunicator.is_in_dialogue : 
		manageInput(delta)
	else : 
		$Sprite2D.play("default")

func manageInput(delta) -> void: #manage movements
	
	direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	if direction.x > 0 : 
		$Sprite2D.flip_h = false
	elif direction.x < 0 : 
		$Sprite2D.flip_h = true
		
	if direction.x == 0 and direction.y == 0 : 
		$Sprite2D.play("default")
	else :
		$Sprite2D.play("walk")
		
	velocity = lerp(velocity, direction * speed, acceleration*delta)
	move_and_slide()
