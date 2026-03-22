extends Control

signal failed

@export_group("ring")
@export var ring_radius:float = 50
@export var ring_speed:float = 30
@export var ring_acceleration:float = 10
@export var ring_noise_speed:float = 10
@export var ring_direction_noise:Noise
@export var ring_color:Color = Color.DIM_GRAY

@onready var ring_pos:Vector2 = size/2
var ring_velocity:Vector2
var ring_noise_pos:float

@export_group("player")
@export var player_radius:float = 10
@export var player_speed:float = 50
@export var player_acceleration:float = 20
@export var player_color:Color = Color.BEIGE

@onready var player_pos:Vector2 = size/2
var player_velocity:Vector2

func _ready() -> void:
	ring_direction_noise.seed = randi()

func _draw() -> void:
	draw_circle(ring_pos, ring_radius, ring_color)
	draw_circle(player_pos, player_radius, player_color)


func _process(delta: float) -> void:
	# Move player
	var player_dir:Vector2 = Input.get_vector("left", "right", "up", "down").normalized()
	player_velocity = lerp(player_velocity, player_dir * player_speed, player_acceleration * delta)
	player_pos += player_velocity * delta
	player_pos = player_pos.clamp(Vector2.ZERO, size)
	
	# Check player pos
	if player_pos.distance_squared_to(ring_pos) > ring_radius**2:
		failed.emit()
		player_pos = size/2
		ring_pos = size/2
		player_velocity = Vector2.ZERO
		ring_velocity = Vector2.ZERO
	
	# Move ring
	ring_noise_pos += delta * ring_noise_speed
	var ring_dir:Vector2 = Vector2(
		ring_direction_noise.get_noise_2d(ring_noise_pos, 0),
		ring_direction_noise.get_noise_2d(0,ring_noise_pos)
	).normalized()
	ring_velocity = lerp(ring_velocity, ring_dir * ring_speed, ring_acceleration * delta)
	ring_pos += ring_velocity * delta
	ring_pos = ring_pos.clamp(Vector2.ZERO, size)
	
	# Redraw
	queue_redraw()
