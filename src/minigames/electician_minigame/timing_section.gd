
extends Control

signal failed

@export_group("Mechanical")
@export var cube_travel_duration:float = 5
@export var cube_duration:float = 1
@onready var cube_size_scale:float = cube_duration/cube_travel_duration

@export_group("Visual")
@export var cube_base_text:Texture2D
@export var cube_can_be_touched_text:Texture2D
@export var cube_sucess_text:Texture2D
@export var cube_failed_text:Texture2D

var current_cube_touched:bool = false

func _ready() -> void:
	$BaseRect.position.y = -$BaseRect.size.y
	$MockUpRect.position.y = $BaseRect.position.y
	$BaseRect.size.y = size.y * cube_size_scale
	$MockUpRect.size.y = size.y * cube_size_scale

func _draw() -> void:
	pass
	## Draw first cube
	#var cube_size:float = size.y * cube_size_scale
	#var cube_rect:Rect2 = Rect2(0,cube_position_y - cube_size/2,size.x,cube_size)
	#var cube_color:Color = cube_initial_color
	#if abs(cube_position_y - size.y/2) <= (cursor_size + cube_size)/2: cube_color = cube_can_be_touched_color
	#if current_cube_touched: cube_color = cube_touched_color
	#draw_rect(cube_rect, cube_color)
	#
	## Draw second cube (only visual)
	#if cube_position_y + cube_size/2 >= size.y:
	#	cube_rect.position.y -= size.y
	#	draw_rect(cube_rect, cube_initial_color)
	#
	## Draw cursor
	#var cursor_rect:Rect2 = Rect2(0,size.y/2,size.x,cursor_size)
	#draw_rect(cursor_rect, cursor_color)

func _process(delta: float) -> void:
	var speed = size.y / cube_travel_duration
	$BaseRect.position.y += speed * delta
	$MockUpRect.position.y = $BaseRect.position.y - size.y
	
	# Get back up
	if $BaseRect.position.y >= size.y:
		$BaseRect.position.y -= size.y
		current_cube_touched = false
		$BaseRect.texture = cube_base_text
	
	# Can be touched texture
	if $BaseRect.get_rect().has_point(size/2) && !current_cube_touched:
		$BaseRect.texture = cube_can_be_touched_text
	
	# Input
	if Input.is_action_just_pressed("interact2"):
		if $BaseRect.get_rect().has_point(size/2):
			$BaseRect.texture = cube_sucess_text
			current_cube_touched = true
		else:
			$BaseRect.texture = cube_failed_text
			failed.emit()
	
	# Fail
	if $BaseRect.position.y - size.y/2 > 5 && !current_cube_touched:
		$BaseRect.texture = cube_failed_text
		failed.emit()

func reset() -> void:
	$BaseRect.position.y = 0
	$BaseRect.texture = cube_base_text
	current_cube_touched = false
