class_name Target extends Node2D


@export_group("Target Parameters")
@export var max_life_points: int = 3
@export var disappear_time: float = 0.4


@onready var generator_sprite: AnimatedSprite2D = $Generator
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hit_sound: AudioStreamPlayer = $HitSound


var base_scale: Vector2
var life_points: int

signal target_destroyed


func _ready():
	base_scale = generator_sprite.scale
	generator_sprite.scale = Vector2.ZERO
	
	var tween = create_tween()
	tween.tween_property(generator_sprite, "scale", base_scale, 2.0)
	await tween.finished
	
	life_points = max_life_points
	generator_sprite.play("default")


func _on_area_2d_body_entered(body):
	if body is arcade_ball:
		take_hit()


func take_hit():
	life_points -= 1
	
	if hit_sound:
		hit_sound.play()
	
	if life_points <= 0:
		await disappear()
	else:
		play_hit_animation()


func play_hit_animation():
	if animation_player:
		animation_player.play("Hit")


func disappear():
	var tween = create_tween()
	tween.tween_property(generator_sprite, "scale", Vector2.ZERO, disappear_time)
	await tween.finished
	
	target_destroyed.emit()
	queue_free()
