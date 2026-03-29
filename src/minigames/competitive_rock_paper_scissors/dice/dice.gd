class_name Dice extends RigidBody3D

var start_pos
var roll_strength = 70
var is_rolling:bool = false
var has_rolled = false

signal roll_finished(value)
@onready var raycasts = $Raycasts.get_children()


func _ready():
	start_pos = global_position
	
func _process(delta):
	pass
	
func roll():
	# resetting
	sleeping = false
	freeze = false
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Random rotation 
	transform.basis = Basis(Vector3.RIGHT, randf_range(0, 2*PI)) * transform.basis
	transform.basis = Basis(Vector3.UP, randf_range(0, 2*PI)) * transform.basis
	transform.basis = Basis(Vector3.FORWARD, randf_range(0, 2*PI)) * transform.basis
	
	var throw_vector = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
	angular_velocity = throw_vector * roll_strength / 2
	apply_central_impulse(throw_vector*roll_strength)
	
	is_rolling = true
	
	


func _on_sleeping_state_changed():
	print("test")
	if sleeping : 
		var landed_on_side = false
		for raycast in raycasts : 
			if raycast.is_colliding():
				roll_finished.emit(raycast.get_opposite_side())
				is_rolling = false
				landed_on_side = true	
		if landed_on_side:
			roll()
