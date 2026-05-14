class_name Gem extends Area2D



func _ready():
	$AnimatedSprite2D.visible = true
	$DeathParticle.emitting = false
	$AnimatedSprite2D.play("default")
	($AnimatedSprite2D.material as ShaderMaterial).set_shader_parameter("flash", Vector4.ZERO)

func _on_body_entered(body):
	if body is arcadePlayer : 
		body.DieComponent.death()

func disappear():
	monitoring = false
	$AnimationPlayer.play("disappear")
	await $AnimationPlayer.animation_finished
	queue_free()
