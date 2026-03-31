extends RayCast3D

@export var opposite_side:int

func _ready():
	add_exception(owner)

func get_opposite_side() -> int:
	return opposite_side 
