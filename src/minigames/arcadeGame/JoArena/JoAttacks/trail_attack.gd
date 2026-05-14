class_name TrailAttack extends Line2D


var offset:Vector2
var current_point_count:int
var ball_pos:Vector2
var max_points:int = 60
var min_points:int = 4
var max_distance = 100
var queue:Array=[]
var longueurMax = 50
var speed = 200

var previous_position:Vector2
@export var player:arcadePlayer
@export var hitbox_width:int

@export var hitbox:Area2D
@export var collision_shape:CollisionPolygon2D

func _ready():
	add_point(Vector2.ZERO)
	add_point(Vector2.ZERO+Vector2.ONE*5)
	previous_position = Vector2.ZERO
	
func _physics_process(delta):
	update_hitbox()
	if player != null : 
		var direction: Vector2 = (player.global_position - to_global(get_point_position(get_point_count() - 1))).normalized()
		var next_point_position: Vector2 = to_global(get_point_position(get_point_count() - 1)) + speed * direction *delta
		add_point(to_local(next_point_position))

		if get_point_count() > max_points:
			remove_point(0)

		previous_position = global_position


func manage_points_trail(ball_position: Vector2):
	var local_ball_position := to_local(ball_position)

	for i in range(get_point_count() - 1, -1, -1):
		if get_point_position(i).distance_to(local_ball_position) > max_distance:
			remove_point(i)
			
func increase_max_points(i:int):
	max_points +=i
	
func update_hitbox():
	if get_point_count() < 2:
		return
	#le filtered point est simplement là pour éviter l'erreur de décomposition du polygon qui crash pas le jeu mais qui crée tt de même une erreur
	var filtered_points:Array[Vector2] = []

	for i in range(get_point_count()):
		var p = get_point_position(i)

		if filtered_points.size() == 0:
			filtered_points.append(p)
		elif filtered_points[filtered_points.size() - 1].distance_to(p) > 4.0:
			filtered_points.append(p)

	if filtered_points.size() < 2:
		return

	var left_side:Array[Vector2] = []
	var right_side:Array[Vector2] = []

	for i in range(filtered_points.size()):
		var dir:Vector2

		if i == 0:
			dir = filtered_points[1] - filtered_points[0]
		elif i == filtered_points.size() - 1:
			dir = filtered_points[i] - filtered_points[i - 1]
		else:
			dir = filtered_points[i + 1] - filtered_points[i - 1]

		if dir.length() < 0.001:
			continue

		dir = dir.normalized()

		var normal = Vector2(-dir.y, dir.x)

		var left_point = filtered_points[i] + normal * hitbox_width * 0.5
		var right_point = filtered_points[i] - normal * hitbox_width * 0.5

		left_side.append(left_point)
		right_side.insert(0, right_point)

	if left_side.size() < 2 or right_side.size() < 2:
		return

	var polygon:PackedVector2Array = PackedVector2Array()
	polygon.append_array(left_side)
	polygon.append_array(right_side)

	collision_shape.polygon = polygon

	
			
			
	





func _on_hit_box_body_entered(body):
	print("test")
	if body is arcadePlayer : 
		print("test")
		body.DieComponent.death()
		queue_free()
