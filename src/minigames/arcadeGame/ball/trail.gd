extends Line2D

var offset:Vector2
var current_point_count:int
var ball_pos:Vector2
var max_points:int = 60
var min_points:int = 4
var max_distance = 100
var queue:Array=[]
var longueurMax = 50

var previous_position:Vector2
@onready var ball = $"../.."
@export var ball_radius = 16

func _ready():
	previous_position = get_parent().global_position
	
func _process(delta):
	var current_position: Vector2 = get_parent().global_position
	var direction: Vector2 = (current_position - previous_position).normalized()
	var next_point_position: Vector2 = current_position - ball_radius * direction * ball.scale
	
	manage_points_trail(current_position)
	add_point(to_local(next_point_position))

	if get_point_count() > max_points:
		remove_point(0)

	previous_position = current_position


func manage_points_trail(ball_position: Vector2):
	var local_ball_position := to_local(ball_position)

	for i in range(get_point_count() - 1, -1, -1):
		if get_point_position(i).distance_to(local_ball_position) > max_distance:
			remove_point(i)
			
func increase_max_points(i:int):
	max_points +=i
	
