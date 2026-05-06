extends Node2D


@onready var JoBall:PackedScene = load("res://src/minigames/arcadeGame/JoArena/JoBalls.tscn")
@onready var ball_spawn_path = $Path2D/BallSpawnPosition
@onready var player:arcadePlayer = $"../Entities/Player"
@onready var attacks = $Attacks

@onready var particles = $"../CPUParticles2D"
@onready var fond = $"../TextureRect"
@export_group("Ball Attack")
@export var turn_back_timer:float = 2.5

func _ready():
	pass
	
func ball_attack(nb_ball:int = 3):
	for i in range(nb_ball):
		var ball:Jo_ball = JoBall.instantiate()
		ball.set_player(player)
	
		
		ball.set_timer(turn_back_timer)
		ball_spawn_path.progress_ratio = float(i)/float(nb_ball)
		var ball_spawn_position = ball_spawn_path.position
		print(ball_spawn_position)
		ball.global_position = ball_spawn_position
		
		attacks.add_child(ball)
		ball.call_deferred("update_direction", player.global_position - ball.global_position)

func start_fight():
	await  get_tree().create_timer(1).timeout
	place_transition()
	
func reset():
	for ent in attacks.get_children() : 
		ent.queue_free()
		
func place_transition():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(particles, "modulate", Color.BLACK, 3)
	tween.parallel().tween_property(fond, "color", Color("#b9b9b9"),3)
