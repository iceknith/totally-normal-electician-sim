extends Control

signal failed

@export_group("bolt")
@export var bolt_speed:float = 30
@export var bolt_acceleration:float = 10
@export var bolt_noise_speed:float = 10
@export var bolt_direction_noise:Noise
var bolt_velocity:Vector2
var bolt_noise_pos:float

@export_group("player")
@export var player_speed:float = 50
@export var player_acceleration:float = 20

@onready var player_pos:Vector2 = size/2
var player_velocity:Vector2

func _ready() -> void:
	bolt_direction_noise.seed = randi()
	$Bolt.position = size/2
	$Pince.position = size/2

func _process(delta: float) -> void:
	# Move screw
	var player_dir:Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	player_velocity = lerp(player_velocity, player_dir * player_speed, player_acceleration * delta)
	$Pince.position += player_velocity * delta
	$Pince.position = $Pince.position.clamp(Vector2.ZERO, size)
	
	# Move bolt
	bolt_noise_pos += delta * bolt_noise_speed
	var bolt_dir:Vector2 = Vector2(
		bolt_direction_noise.get_noise_2d(bolt_noise_pos, 0),
		bolt_direction_noise.get_noise_2d(0,bolt_noise_pos)
	).normalized()
	bolt_velocity = lerp(bolt_velocity, bolt_dir * bolt_speed, bolt_acceleration * delta)
	$Bolt.position += bolt_velocity * delta
	$Bolt.position = $Bolt.position.clamp(Vector2.ZERO, size)

func reset() -> void:
	bolt_direction_noise.seed = randi()
	$Bolt.position = size/2
	$Pince.position = size/2
	player_velocity = Vector2.ZERO
	bolt_velocity = Vector2.ZERO

func _on_pince_area_entered(_area: Area2D) -> void:
	failed.emit()
