class_name slash_attack extends Node2D

@onready var fire = $Fire
@onready var slash = $Slash
@onready var warning = $warning
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fire_hitbox = $FireHitbox
@onready var slash_hitbox = $SlashHitbox


@export var fire_life_time: float = 15
@export var tracking_time: float = 2
@export var tracking_speed: float = 290
@export var wait_before_slash:float = 0.25
@export var blink_time: float = 0.15

@export var player: arcadePlayer

var tracking: bool = false
var removing_fire = false

func _ready():
	if player != null : 
		global_position = player.global_position
	warning.modulate = Color.BLACK
	fire.visible = false
	fire.scale = Vector2.ZERO
	slash.visible = false

	warning.visible = true
	fire_hitbox.monitoring = false
	slash_hitbox.monitoring = false

	start_tracking_warning()


func _process(delta):
	if tracking and player != null:
		var direction = global_position.direction_to(player.global_position)
		global_position += direction * tracking_speed * delta
		
		
	if fire.scale.x > 0.5 and  fire.scale.y > 0.5 : 
		fire_hitbox.monitoring = true
	else : 
		fire_hitbox.monitoring = false
		


func start_tracking_warning():
	tracking = true

	var elapsed: float = 0.0
	var is_red: bool = true

	while elapsed < tracking_time:

		if is_red:
			warning.modulate = Color.RED
		else:
			warning.modulate = Color.WHITE

		is_red = !is_red

		await get_tree().create_timer(blink_time).timeout
		elapsed += blink_time

	tracking = false
	

	$PreventSound.play()
	await get_tree().create_timer(wait_before_slash).timeout
	slash_attack_animation()
	warning.visible = false


func slash_attack_animation():
	##slash_hitbox.monitoring = true
	##$SlashSoundEffect.pitch_scale = randf_range(0.6, 2)
	##animation_player.play("slash")
	#await animation_player.animation_finished

	fire.visible = true
	fire.play("default")

	fire.scale = Vector2.ZERO

	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	fire_hitbox.monitoring = true

	tween.tween_property(fire, "scale", Vector2.ONE, 2)

	await tween.finished

	await get_tree().create_timer(fire_life_time).timeout
	
	tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(fire, "scale", Vector2.ZERO, 2)

	await tween.finished

	queue_free()


func set_player(p):
	player = p


func _on_slash_hitbox_body_entered(body):
	if body is arcadePlayer : 
		body.DieComponent.death()


func _on_fire_hitbox_body_entered(body):
	if body is arcadePlayer : 
		body.DieComponent.death()
	
func removing_fire_early():
	var tween = create_tween()

	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_IN)

	tween.tween_property(fire, "scale", Vector2.ZERO, 2)

	await tween.finished

	queue_free()
func get_fire_life_time():
	return fire_life_time
func get_tracking_time():
	return tracking_time
