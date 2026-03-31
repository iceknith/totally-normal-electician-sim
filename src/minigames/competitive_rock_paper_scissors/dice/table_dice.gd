extends Node3D


@export var starting_pos:Vector3 = Vector3(0, 5, 0)
@onready var dice = $Dice

func _ready(): 
	pass
	
func reset_and_roll():
	dice.position = starting_pos
	dice.roll()
	
