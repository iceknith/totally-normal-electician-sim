class_name Die extends Area2D

@export var losing_ball_state:ArcadeGame.BALLSTATE #ball state that defeats the entity
@export var animationPlayer:AnimationPlayer
@export var death_animation_name:String


signal die(loser)

var can_die:bool 
func _ready(): 
	can_die = true



func turn_off():
	monitoring = false
	
func turn_on() : 
	monitoring = true
	
func _on_body_entered(body):
	if body is arcade_ball : 
		if body.get_ball_state() == losing_ball_state and can_die:
			death()

func death():
	die.emit(get_parent())
	death_animation()

func death_animation():
	animationPlayer.play(death_animation_name)
	
