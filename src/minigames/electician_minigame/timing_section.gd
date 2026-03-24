extends Control

signal failed

@export_group("Mechanical")
@export var cube_travel_duration:float = 5
@export var cube_duration:float = 1
@onready var cube_size_scale:float = cube_duration/cube_travel_duration

@export_group("Visual")
@export var cursor_size:float = 5
@export var cube_initial_color:Color = Color.INDIAN_RED
@export var cube_can_be_touched_color:Color = Color.PALE_VIOLET_RED
@export var cube_touched_color:Color = Color.PALE_GREEN
@export var cursor_color:Color = Color.GOLD

var cube_position_y:float = 0
var cursor_position_y:float = size.y/2
var current_cube_touched:bool = false

func _draw() -> void:
	# Draw first cube
	var cube_size:float = size.y * cube_size_scale
	var cube_rect:Rect2 = Rect2(0,cube_position_y - cube_size/2,size.x,cube_size)
	var cube_color:Color = cube_initial_color
	if abs(cube_position_y - size.y/2) <= (cursor_size + cube_size)/2: cube_color = cube_can_be_touched_color
	if current_cube_touched: cube_color = cube_touched_color
	draw_rect(cube_rect, cube_color)
	
	# Draw second cube (only visual)
	if cube_position_y + cube_size/2 >= size.y:
		cube_rect.position.y -= size.y
		draw_rect(cube_rect, cube_initial_color)
	
	# Draw cursor
	var cursor_rect:Rect2 = Rect2(0,size.y/2,size.x,cursor_size)
	draw_rect(cursor_rect, cursor_color)

func _process(delta: float) -> void:
	var speed = size.y / cube_travel_duration
	cube_position_y += speed * delta
	
	var cube_size:float = size.y * cube_size_scale
	
	if cube_position_y - cube_size/2 >= size.y:
		cube_position_y -= size.y
		current_cube_touched = false
	
	if Input.is_action_just_pressed("jump") || Input.is_action_just_pressed("interract"):
		if abs(cube_position_y - size.y/2) <= (cursor_size + cube_size)/2:
			current_cube_touched = true
		else:
			failed.emit()
	
	if cube_position_y - size.y/2 > cursor_size + cube_size && !current_cube_touched:
		failed.emit()
	
	queue_redraw()

func reset() -> void:
	cube_position_y = 0
	current_cube_touched  =false
