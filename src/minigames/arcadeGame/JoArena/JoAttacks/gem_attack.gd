class_name gemAttack extends Node2D


@export var ball_state_to_give:ArcadeGame.BALLSTATE
@export var losing_ball_state:ArcadeGame.BALLSTATE


@export_group("Attack Parameters : ")
@export var max_life_points = 3
@export var rotation_speed = 0.1
@export var rotate_left:bool
@export var ball_color:Color
@export var min_switch_rot:float
@export var max_switch_rot:float



@export_group("Spiral Parameters : ")
@export var offset:int
@export var number_of_line:int  = 4
@export var nb_projectile_per_line:int = 5
@export var distance_between_projectiles = 20









@export var gather_time: float = 3.0
@export var spread_time: float = 1.5
@export var pattern_spacing: Vector2 = Vector2(80, 60)

var gem_pattern := [
	Vector2(-3, -2), Vector2(0, -2), Vector2(3, -2),
	Vector2(-2, -1), Vector2(1, -1),
	Vector2(-3, 0), Vector2(0, 0), Vector2(3, 0),
	Vector2(-1, 1), Vector2(2, 1),
	Vector2(-3, 2), Vector2(0, 2), Vector2(3, 2)
]


@export_group("Sprite Parameters")
@export var generator_sprite_size:int = 32
@export var gem_sprite_size:int = 16




@onready var gem_rotation = $GemRotation

@onready var generator_sprite:AnimatedSprite2D = $Generator
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var ball = load("res://src/minigames/arcadeGame/ball.tscn")
@onready var gem:PackedScene = load("res://src/minigames/arcadeGame/JoArena/JoAttacks/gem.tscn")


var base_scale
var life_points
var gem_dict = {}

enum FormState {
	SPIRAL,
	PATTERN
}

var current_form: FormState = FormState.SPIRAL
var is_switching_form: bool = false

signal attack_ended


func _ready():
	base_scale = generator_sprite.scale
	generator_sprite.scale = Vector2(0,0)
	var tween = create_tween()
	tween.tween_property(generator_sprite, "scale", base_scale, 2)
	await tween.finished
	life_points = max_life_points
	generator_sprite.play("default")
	create_attack()
	
func _process(delta):
	if rotate_left : 
		gem_rotation.rotation += delta*rotation_speed
	else : 
		gem_rotation.rotation -= delta*rotation_speed


func _on_area_2d_body_entered(body):
	if body is arcade_ball : 
		if body.get_ball_state() == losing_ball_state : 
			lose(body)
			
		

func create_attack():
	var spacing = gem_sprite_size + distance_between_projectiles
	var angle_offset = deg_to_rad(offset) # offset en degrés 

	for l in range(number_of_line):
		var base_angle = l * 2*PI / number_of_line

		for p in range(nb_projectile_per_line):
			var radius = generator_sprite_size + p * spacing
			
			# plus p augmente plus l'angle tourne légèrement
			var angle = base_angle + p * angle_offset
			var dir = Vector2.from_angle(angle)

			var pos = dir * radius

			var gem_ent = gem.instantiate()
			gem_rotation.add_child(gem_ent)
			gem_dict[gem_ent] = pos
			
			var tween = create_tween()
			tween.tween_property(gem_ent, "position", pos, 1.5)
			
			
			
	
func play_hit_animation():
	animation_player.play("Hit")
	
func lose(body:arcade_ball):
	life_points = life_points - 1
	$HitSound.play()
	if life_points == 0 : 
		end_attack()
	else : 
		body.update_ball_state(ball_state_to_give)
		body.update_ball_color(ball_color)
		body.mouvement_component.increase_move_speed(40)
		play_hit_animation()

func get_state():
	return ball_state_to_give
		


func assemble():
	var gems = gem_dict.keys()
	var gather_tween = create_tween()
	gather_tween.set_parallel(true)
	
	for g in gems:
		gather_tween.tween_property(g, "position", Vector2.ZERO, gather_time)
	
	await gather_tween.finished
	
	
func move_to_pattern():
	var gems = gem_dict.keys()
	var spread_tween = create_tween()
	spread_tween.set_parallel(true)
	
	for i in range(gems.size()):
		if i >= gem_pattern.size():
			break
		
		var g = gems[i]
		
		if not is_instance_valid(g):
			continue
		
		var target_position = gem_pattern[i] * pattern_spacing
		
		spread_tween.tween_property(g, "position", target_position, spread_time)
	
	await spread_tween.finished
	
	
func move_to_spiral():
	var tween = create_tween()
	tween.set_parallel(true)
	
	for g in gem_dict : 
		if not is_instance_valid(g):
			continue
		
		tween.tween_property(g, "position", gem_dict[g], spread_time)
	
	await tween.finished


func switch_form():
	
	if is_switching_form:
		return
	
	is_switching_form = true
	
	await assemble()
	
	if current_form == FormState.SPIRAL:
		await move_to_pattern()
		current_form = FormState.PATTERN
	else:
		await move_to_spiral()
		current_form = FormState.SPIRAL
	
	is_switching_form = false


func _on_timer_timeout():
	switch_form()


func _on_switch_rot_timeout():
	$PreventSound.play()
	await get_tree().create_timer(0.75).timeout
	rotate_left = !rotate_left
	$SwitchRot.wait_time = randi_range(min_switch_rot, max_switch_rot)
	$SwitchRot.start()
	
func disappear_gem():
	var i = 0
	for g in gem_dict : 
		if i == (gem_dict.size() - 1):
			await g.disappear()
		else : 
			g.disappear()
		i +=1
		
func end_attack():
	
	await disappear_gem()
	await get_tree().create_timer(0.25).timeout
	attack_ended.emit()
	queue_free()
	
