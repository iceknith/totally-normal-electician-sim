extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var look_sensitivity : float = 0.006

func _ready() -> void:
	# plus tard on voudra avoir des moments ou on libère le curseur pour pouvoir acceder à l'ui au lieu qu'il serve à tourner la drirection dans laquelle on regarde.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# tourne le perso sur l'axe droite/gauche
			rotate_y(-event.relative.x * look_sensitivity)
			# tourne la caméra de haut en bas
			%Camera3D.rotate_x(-event.relative.y * look_sensitivity)
			# contraint la rotation de la caméra pour éviter que le joueur puisse se tordre le cou
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
