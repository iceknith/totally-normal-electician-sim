class_name player2D extends CharacterBody2D


@export var speed = 300
@export var acceleration = 20


var direction:Vector2


			
func _process(delta):
	manageInput(delta)
	manageInteractionAreas()
	
	
func _ready():
	pass
	
	
func manageInput(delta) -> void: #manage movements
	direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	velocity = lerp(velocity, direction * speed, acceleration*delta)
	move_and_slide()
	

func manageInteractionAreas(): #check which Area2d to turn on and off
	var interactable = get_first_interactable()
	if interactable !=null : 
		interactable.is_viewed = true
		
	
func enable_only_one_area(direction) -> void : #turn on only one interaction Area and disables the others, finalement je me suis dit que j'allais utiliser une seule area2d pour l'instant et pis on verra quand j'aurai les anim pour setup un truc plus clean
	pass
	
func get_first_interactable(): #get the first interactable
	for area in $DetectInteractions/Area2D.get_overlapping_areas():
		if area is Interactable2D:
			return area
	return null
