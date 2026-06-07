extends Node2D


@onready var JoBall:PackedScene = load("res://src/minigames/arcadeGame/JoArena/JoBalls.tscn")
@onready var SlashAttack:PackedScene = load("res://src/minigames/arcadeGame/JoArena/JoAttacks/slash.tscn")
@onready var GemAttack:PackedScene = load("res://src/minigames/arcadeGame/JoArena/JoAttacks/gemAttack.tscn")
@onready var ball:PackedScene = load("res://src/minigames/arcadeGame/ball.tscn")
@onready var jo_manager:PackedScene = load("res://src/minigames/arcadeGame/jo_manager.tscn")
@onready var jo:PackedScene = load("res://src/minigames/arcadeGame/enemy/Little'Joe.tscn")

@onready var ball_spawn_path = $Path2D/BallSpawnPosition
@onready var player:arcadePlayer = $"../Entities/Player"
@onready var attacks = $Attacks
@onready var Camera =$"../Camera2D"

@onready var particles = $"../CPUParticles2D"
@onready var fond = $"../TextureRect"


@export_group("Ball Attack")
@export var turn_back_timer:float = 2.5
@export var balls_life_time = 10
@export var nb_ball:int = 3
@export var time_between_ball_spawn:int = 3
var ball_pool: Array[Jo_ball] = [] #sinon ça lag

var slash_pool:Array[slash_attack]

@export_group("Slash Attack")
@export var slash_number:int = 10
@export var slash_interval:float = 0.5
@export var slash_interval_curve:Curve

@export_group("Gem Attack")
@export var gem_attack_duration:int = 10
@export var ball_color:Color
@export var ball_base_speed:int = 400


var jo_manager_ent:JoManager
var jo_ent:ArcadeEnemy


var slash_time = 0#to know how much the slash attack last which is now the fire attack
var fight_id = 0

signal fight_over

func _ready():
	fight_id = 0

func ball_attack(id = fight_id):
	for i in range(nb_ball):
		if fight_id != id:
			return

		var jo_ball: Jo_ball = JoBall.instantiate()
		jo_ball.set_player(player)
		jo_ball.set_timer(turn_back_timer)
		jo_ball.set_life_time(balls_life_time)

		jo_ball.visible = true
		attacks.add_child(jo_ball)

		jo_ball.update_ball_color(ball_color)
		ball_pool.append(jo_ball)

		ball_spawn_path.progress_ratio = float(i) / float(nb_ball)
		jo_ball.global_position = ball_spawn_path.global_position
		jo_ball.process_mode = Node.PROCESS_MODE_INHERIT

		var direction: Vector2 = player.global_position - jo_ball.global_position
		jo_ball.update_direction(direction.normalized())

		# Délai avant la prochaine boule, sauf après la dernière
		if i < nb_ball - 1:
			await get_tree().create_timer(time_between_ball_spawn).timeout





func start_fight(id):
	if fight_id != id :
		return
	await ball_attack(id)
	if fight_id != id :
		return
	await get_tree().create_timer(balls_life_time + 1).timeout
	if fight_id != id :
		return
	await get_tree().create_timer(1).timeout
	if fight_id != id :
		return
	await start_slash_attack(id)
	await get_tree().create_timer(3.0).timeout
	if fight_id != id :
		return
	await remove_fire()
	await get_tree().create_timer(3.0).timeout
	if fight_id != id :
		return
	create_gem_attack()
	
	
func reset():
	reset_place()
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
		if fight_id != id : 
			return
		if is_instance_valid(slash) : 
			slash_pool.append(slash)
	
#remove the fire at the end of attacks
func remove_fire():
	for s in slash_pool : 
		if is_instance_valid(s): #heck if they didnt already queue free 
			s.removing_fire_early()

func create_gem_attack(id = fight_id):
	
	#creates jo at the center he ll be released at the end of the attack
	jo_ent = jo.instantiate()

	attacks.add_child(jo_ent)

	jo_ent.DieComponent.die.connect(end_fight)
	jo_ent.scale = Vector2(0.5, 0.5)
	jo_ent.global_position = Vector2(1152/2, 648/2)
	
	
	var gem_attack:gemAttack = GemAttack.instantiate()
	

	gem_attack.attack_ended.connect(unpause_jo_manager)
	attacks.add_child(gem_attack) 
	gem_attack.global_position = Vector2(1152/2, 648/2) # center the jem attack
	await get_tree().create_timer(4).timeout
	var ball_ent:arcade_ball = ball.instantiate()

	
	if fight_id != id : 
			return
	var dir = (player.global_position - gem_attack.global_position).normalized()
	var pos =  Vector2(1152/2, 648/2) + dir * 50

	
	
	#On ajoute juste Jo et le manager qu'on mettra en route quand l'attaque sera terminé
	jo_manager_ent = create_jo_manager(jo_ent, ball_ent)
	jo_manager_ent.distance_to_hit = 125
	attacks.add_child(jo_manager_ent)
	jo_ent.set_aiming_direction(dir)
	jo_ent.facing_direction = dir
	
	attacks.add_child(ball_ent)
	ball_ent.mouvement_component.set_speed(ball_base_speed)
	ball_ent.update_ball_state(gem_attack.ball_state_to_give)
	ball_ent.update_ball_color(gem_attack.ball_color)
	ball_ent.set_moving(true)
	ball_ent.global_position = pos
	
	jo_ent.HitBallComponent.update_launching_ball_direction(dir)
	jo_ent.HitBallComponent.set_direction(dir)
	
	await get_tree().physics_frame
	
	if fight_id != id : 
			return
	
	jo_ent.HitBallComponent.hit_ball()



		
func reset_place():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(particles, "modulate", Color.WHITE, 1)
	tween.parallel().tween_property(fond, "color", Color.BLACK,1)
	

	
func create_jo_manager(jo_ent:ArcadeEnemy, ball_ent :arcade_ball):
	var manager: JoManager = jo_manager.instantiate()
	
	manager.enemy = jo_ent
	manager.player = player
	manager.ball = ball_ent
	manager.set_preset(JoManager.opponent.Jo)
	manager.apply_jo_preset()
	manager.pause_movement = true
	return manager
	
	
func unpause_jo_manager():
	if jo_manager_ent is JoManager : 
		jo_manager_ent.pause_movement = false

	

func end_fight(loser):
	
	player.DieComponent.can_die = false
	SoundManager.stop_music.emit(2)
	jo_manager_ent.pause_movement = true
	Engine.time_scale = 0.4
	#camera zoom
	jo_ent.DieComponent.play_death_sound()

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(Camera, "global_position", jo_ent.global_position, 1)
	tween.parallel().tween_property(Camera, "zoom", Vector2(1.5, 1.5) , 1)
	
	await tween.finished
	Engine.time_scale = 1
	
	Camera.reset_camera()
	
	for ent in attacks.get_children() : 
		ent.queue_free()
	fight_over.emit()
	
