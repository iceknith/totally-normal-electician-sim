class_name Player extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var look_sensitivity : float = 0.006
var rotation_y = 0
var rotation_x = 0

var lock_camera:bool

func _ready() -> void:
	# plus tard on voudra avoir des moments ou on libère le curseur pour pouvoir acceder à l'ui au lieu qu'il serve à tourner la drirection dans laquelle on regarde.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

			
func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion and !in_interaction():
			rotation_y -= event.relative.x * look_sensitivity # tourne le perso sur l'axe droite/gauche
			rotation_x -= event.relative.y * look_sensitivity 	# tourne la caméra de haut en bas
			
			# contraint la rotation de la caméra pour éviter que le joueur puisse se tordre le cou
			rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
			
			rotation.y = rotation_y
			%Camera3D.rotation.x = rotation_x

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Handle Interactable Vision
	interactable_vision_handler(delta)

func interactable_vision_handler(delta) -> void: 
	# Handle the interactable vision
	# Notifies an interactable object that it is being looked at
	var collider:Area3D = $head/Camera3D/InteractableVision.get_collider()
	if collider && (collider as Interractable):
		collider.player_viewing()
		collider.get_player_camera(%Camera3D)
		
func in_interaction() -> bool: 
	match MainCommunicator.current_state : 
		MainCommunicator.GameState.Dialogue : 
			return true 
		MainCommunicator.GameState.MiniGame : 
			return true
	return false
			
	


	

	
