#extends Node2D

#@onready var trail_a: CPUParticles2D = $TrailA
#@onready var trail_b: CPUParticles2D = $TrailB
#
#@export var wave_amplitude := 18.0
#@export var wave_frequency := 12.0
#
#@onready var ball = $".."
#
#var t = 0.0
#
#func _process(delta):
	#t += delta
	#
	#if ball.velocity.length() > 10:
		#trail_a.emitting = true
		#trail_b.emitting = true
		#
		#var dir = ball.velocity.normalized()
		#var perpendicular := Vector2(-dir.y, dir.x)
		#
		#var wave := sin(t * wave_frequency) * wave_amplitude
		#
		#trail_a.global_position = global_position + perpendicular * wave
		#trail_b.global_position = global_position - perpendicular * wave
		#
		#trail_a.global_rotation = ball.velocity.angle() + PI
		#trail_b.global_rotation = ball.velocity.angle() + PI
	#else:
		#trail_a.emitting = false
		#trail_b.emitting = false
