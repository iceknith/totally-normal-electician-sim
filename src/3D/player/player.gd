class_name Player extends CharacterBody3D

const SPEED = 7.5
const JUMP_VELOCITY = 4.5
const MAX_STEP_UP = 0.5

@export var look_sensitivity : float = 0.006
var rotation_y = 0
var rotation_x = 0

var lock_camera:bool
var eow_meter:float = 0

@export_group("Walk Jitter")
@export var walk_jitter_strength:float = 0.5
@export var walk_jitter_speed:float = 5
@export var walk_jitter_noise:Noise
@export var walk_jitter_curve:Curve
var walk_jitter_noise_pos:float

func _ready() -> void:
	# plus tard on voudra avoir des moments ou on libère le curseur pour pouvoir acceder à l'ui au lieu qu'il serve à tourner la drirection dans laquelle on regarde.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion && !in_interaction():
			# Si l'input ne match pas avec la vélocité rentré on ne le process pas
			# Sinon, ça fait des flicker bizzare quand on sort des dialogues
			if abs(event.relative.x) >= abs(event.velocity.x) &&\
				abs(event.relative.y) >= abs(event.velocity.y): 
					return
			
			rotation_y -= event.relative.x * look_sensitivity # tourne le perso sur l'axe droite/gauche
			rotation_x -= event.relative.y * look_sensitivity 	# tourne la caméra de haut en bas
			
			# contraint la rotation de la caméra pour éviter que le joueur puisse se tordre le cou
			rotation_x = clamp(rotation_x, deg_to_rad(-90), deg_to_rad(90))
			
			rotation.y = rotation_y
			%Camera3D.rotation.x = rotation_x

func _physics_process(delta: float) -> void:
	#Handles movement
	if !in_interaction() : #check if we are in an interaction
		manage_input(delta)
		# Handle Interactable Vision
		interactable_vision_handler(delta)

func interactable_vision_handler(delta) -> void: 
	# Handle the interactable vision
	# Notifies an interactable object that it is being looked at
	var collider:Area3D = $head/Camera3D/InteractableVision.get_collider()
	if collider && (collider as Interractable):
		collider.player_viewing()
		
func in_interaction() -> bool: 
	return MainCommunicator.is_in_dialogue ||\
		 MainCommunicator.current_state != MainCommunicator.GameState.Game3D

func manage_input(delta:float) -> void :
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction: 
		# Add the random offset
		var walk_jitter_wet:float = walk_jitter_curve.sample(eow_meter)
		walk_jitter_noise_pos += delta * walk_jitter_speed * walk_jitter_wet
		var jitter_offset:Vector2 = walk_jitter_strength * walk_jitter_wet * Vector2(
						walk_jitter_noise.get_noise_2d(walk_jitter_noise_pos,0), 
						walk_jitter_noise.get_noise_2d(0,walk_jitter_noise_pos)
					)
		direction += transform.basis * Vector3(jitter_offset.x, 0, jitter_offset.y)
		
		# Normalize but only if going too fast
		if direction.length_squared() >= 1: direction = direction.normalized() 
		
		# Move the player
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	step_up_handler(delta)
	
	move_and_slide()

func step_up_handler(delta):
	if velocity.x <= 0.01 && velocity.z <= 0.01:
		return
	
	var wish_dir:Vector3 = velocity * delta
	
	# 0. Initialize testing variables
	var body_test_params = PhysicsTestMotionParameters3D.new()
	var body_test_result = PhysicsTestMotionResult3D.new()

	var test_transform = global_transform				## Storing current global_transform for testing
	body_test_params.from = self.global_transform		## Self as origin point
	body_test_params.motion = wish_dir					## Go forward by current distance

	# Pre-check: Are we colliding?
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		## If we don't collide, return
		return

	# 1. Move test_transform to collision location
	var remainder = body_test_result.get_remainder()							## Get remainder from collision
	test_transform = test_transform.translated(body_test_result.get_travel())	## Move test_transform by distance traveled before collision

	# 2. Move test_transform up to ceiling (if any)
	var step_up = MAX_STEP_UP * up_direction
	body_test_params.from = test_transform
	body_test_params.motion = step_up
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3. Move test_transform forward by remaining distance
	body_test_params.from = test_transform
	body_test_params.motion = remainder
	PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
	test_transform = test_transform.translated(body_test_result.get_travel())

	# 3.5 Project remaining along wall normal (if any)
	## So you can walk into wall and up a step
	if body_test_result.get_collision_count() != 0:
		remainder = body_test_result.get_remainder().length()

		### Uh, there may be a better way to calculate this in Godot.
		var wall_normal = body_test_result.get_collision_normal()
		var dot_div_mag = wish_dir.dot(wall_normal) / (wall_normal * wall_normal).length()
		var projected_vector = (wish_dir - dot_div_mag * wall_normal).normalized()

		body_test_params.from = test_transform
		body_test_params.motion = remainder * projected_vector
		PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result)
		test_transform = test_transform.translated(body_test_result.get_travel())
	
	# 4. Move test_transform down onto step
	body_test_params.from = test_transform
	body_test_params.motion = MAX_STEP_UP * -up_direction

	# Return if no collision
	if !PhysicsServer3D.body_test_motion(self.get_rid(), body_test_params, body_test_result):
		return

	test_transform = test_transform.translated(body_test_result.get_travel())

	# 5. Check floor normal for un-walkable slope
	# We don't apply this one because it isn't relevant, and bugs out for slower movements
	#var surface_normal = body_test_result.get_collision_normal()
	#if (snappedf(surface_normal.angle_to(up_direction), 0.001) > floor_max_angle):
	#	return

	# 6. Move player up
	var global_pos = global_position
	velocity.y = 0
	global_pos.y = test_transform.origin.y
	global_position = global_pos
