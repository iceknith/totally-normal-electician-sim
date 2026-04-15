extends CharacterBody2D

@export var speed = 300
@export var acceleration = 20
var direction:Vector2



func _ready():
	pass
	
	
func _process(delta):
	manageInput(delta)
	
	
func _draw():
	var center = get_viewport_rect().size / 2
	draw_circle(global_position,100, Color.WHITE, false, 5)
	
	
func manageInput(delta) -> void: #manage movements
	direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	velocity = lerp(velocity, direction * speed, acceleration*delta)
	move_and_slide()
