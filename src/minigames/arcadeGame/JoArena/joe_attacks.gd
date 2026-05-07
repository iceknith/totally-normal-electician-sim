extends Node2D


@onready var JoBall:PackedScene = load("res://src/minigames/arcadeGame/JoArena/JoBalls.tscn")
@onready var SlashAttack:PackedScene = load("res://src/minigames/arcadeGame/JoArena/JoAttacks/slash.tscn")

@onready var ball_spawn_path = $Path2D/BallSpawnPosition
@onready var player:arcadePlayer = $"../Entities/Player"
@onready var attacks = $Attacks

@onready var particles = $"../CPUParticles2D"
@onready var fond = $"../TextureRect"


@export_group("Ball Attack")
@export var turn_back_timer:float = 2.5
@export var balls_life_time = 10
@export var nb_ball:int = 3
var ball_pool: Array[Jo_ball] = [] #sinon ça lag

var slash_pool:Array[slash_attack]

@export_group("Slash Attack")
@export var slash_number:int = 10
@export var slash_interval:float = 0.5
@export var slash_interval_curve:Curve


var slash_time = 0#to know how much a slash last


var fight_id = 0


func _ready():
	fight_id = 0

func ball_attack():
	for i in range(nb_ball):
		var ball: Jo_ball = JoBall.instantiate()
		ball.set_player(player)
		ball.set_timer(turn_back_timer)
		ball.set_life_time(balls_life_time)
		ball.visible = true
		attacks.add_child(ball)
		ball_pool.append(ball)
	

		ball_spawn_path.progress_ratio = float(i) / float(nb_ball)
		ball.global_position = ball_spawn_path.global_position

		
		ball.process_mode = Node.PROCESS_MODE_INHERIT

		var direction:Vector2 = player.global_position - ball.global_position
		ball.update_direction(direction.normalized())





func start_fight(id):
	if fight_id != id :
		return
	ball_attack()
	if fight_id != id :
		return
		
	await get_tree().create_timer(balls_life_time + 1).timeout
	
	if fight_id != id :
		return
	place_transition()
	await get_tree().create_timer(1).timeout
	
	if fight_id != id :
		return
	await start_slash_attack(id)
	await get_tree().create_timer(slash_time).timeout
	if fight_id != id :
		return
		
	remove_fire()
	
	
func reset():
	fight_id +=1
	for ent in attacks.get_children() : 
		ent.queue_free()
		
func place_transition():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(particles, "modulate", Color.BLACK, 3)
	tween.parallel().tween_property(fond, "color", Color("#b9b9b9"),3)
	
func start_slash_attack(id = fight_id):
	for i in range(slash_number): 
		if fight_id != id : 
			return
		var slash = SlashAttack.instantiate()
		slash.set_player(player)
		attacks.add_child(slash)
		var weight = slash_interval_curve.sample(float(i)/float(slash_number))
		slash_time += (slash.get_fire_life_time() + slash.get_tracking_time() + slash_interval*weight)
		if i == 0 : 
			await  get_tree().create_timer(slash_interval).timeout
		await get_tree().create_timer(slash_interval*weight).timeout
		
		slash_pool.append(slash)
	
func remove_fire():
	for s in slash_pool : 
		if is_instance_valid(s): #heck if they didnt already queue free 
			s.removing_fire_early()
