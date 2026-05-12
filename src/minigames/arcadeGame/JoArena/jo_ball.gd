class_name Jo_ball extends arcade_ball

@export var turn_back_time: float
@export var turn_back_speed: float
@export var player:arcadePlayer
@export var life_time = 10
@export var speed_cap = 400
@export var speed_increase_rate = 40

var starting_animation_finished = false
var turn_back_timer: float = 0.0
var life_timer:float = 0.0
var can_turn_back: bool = true
var played_disappear_animation:bool = false



func _ready():
	scale = Vector2(0.01, 0.01)
	appear_animation()
	moving = true
	update_ball_state(ArcadeGame.BALLSTATE.EnemyControl)
	just_realeased.connect(reset_timer)


func _process(delta):
	
	if scale.x < 0.3 and scale.y < 0.3 and life_timer > life_time : 
		$CollisionShape2D.set_deferred("disabled", true)
	if !being_launched and mouvement_component.get_speed() < speed_cap and starting_animation_finished : 
		mouvement_component.increase_move_speed(delta*speed_increase_rate)
	
	if being_launched : 
		turn_back_timer = 0
	else : 
		turn_back_timer += delta

		if turn_back_timer > turn_back_time:
			turn_back()
	if !played_disappear_animation and !being_launched and life_timer > life_time : 
		disappear_animation()
		played_disappear_animation = true
	life_timer +=delta #track life time

func reset_timer():
	turn_back_timer = 0.0
	can_turn_back = true

func turn_back():
	can_turn_back = false
	ball_state = ArcadeGame.BALLSTATE.EnemyControl
	update_ball_color(base_color)
	if player != null : 
		update_direction(player.global_position -global_position)
		
	
func set_timer(t):
	turn_back_time = t

func set_player(p):
	player = p

func appear_animation(): #set up the appearing animation
	var tween = create_tween()
	disable_scale_management = true
	tween.tween_property(self, "scale", Vector2.ONE*1.5, 0.8)
	await tween.finished
	starting_animation_finished = true
	disable_scale_management = false
	
func disappear_animation():
	var tween = create_tween()
	disable_scale_management = true
	tween.tween_property(self, "scale", Vector2.ZERO, 3)
	tween.parallel().tween_property(get_trail(), "width", 0, 3)
	await tween.finished
	force_release.emit()
	queue_free()
	
	
func set_life_time(lt:float): #sets the lifetime of balls
	life_time = lt
	
