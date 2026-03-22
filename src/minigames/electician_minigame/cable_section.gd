extends Control

enum States {
	Idle,
	CableSelected,
}

signal completed

@export var colors:Array[Color] = [Color.LIGHT_CORAL, Color.LIGHT_BLUE, Color.LIGHT_GREEN, Color.LIGHT_PINK]
@export var unselected_color:Color = Color.DARK_GRAY
var cables:Array[Line2D]
var images:Array[Array]
var button_colors:Dictionary[Vector2,int]
@export var grid_size:Vector2 = Vector2(4,4)
@export var min_border_perc:float = 0.2
@export var button_image:Texture2D
@export var cable_image:Texture2D
@export var cable_width:float = 5
@export var max_path_length:float = 3
var border_size:Vector2
var cell_size:Vector2
var circle_size:float

var completed_count:int
@onready var color_count = colors.size()

var current_state:States = States.Idle
var current_color:int
var start_circle_pos:Vector2
var current_circle_pos:Vector2

func _ready() -> void:
	cell_size = size/grid_size
	circle_size = min(cell_size.x, cell_size.y)
	circle_size -= circle_size*min_border_perc
	border_size = cell_size - circle_size*Vector2.ONE
	
	# Create buttons
	var image:TextureRect = TextureRect.new()
	image.texture = button_image
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.size = circle_size * Vector2.ONE
	image.modulate = unselected_color
	
	for x in grid_size.x:
		var line:Array[TextureRect] = []
		images.append(line)
		for y in grid_size.y:
			var new_img = image.duplicate()
			new_img.position = get_screen_pos(Vector2(x,y))
			add_child(new_img)
			line.append(new_img)
	
	# Create cables
	var cable:Line2D = Line2D.new()
	for c in colors:
		var new_cable = cable.duplicate()
		new_cable.modulate = c
		new_cable.width = cable_width
		add_child(new_cable)
		cables.append(new_cable)
	
	init_color_buttons()

func init_color_buttons():
	for i in colors.size():
		# First Image
		var color = colors[i]
		var start:Vector2 = get_random_available_circle()
		if start == -Vector2.ONE: color_count -= 1; break
		set_circle_color(start, i)
		var end:Vector2 = get_random_end_circle(start)
		set_circle_color(end, i)
		for pos in [start, end]:
			var image:TextureRect = images[pos.x][pos.y]
			image.modulate = color
	remove_temp_marks()

func get_random_available_circle() -> Vector2:
	var i = 0
	while i < 10:
		i += 1
		var available_pos:Vector2 = Vector2(randi_range(0,grid_size.x-1), randi_range(0,grid_size.y-1))
		if get_circle_color(available_pos) == -1 && !get_available_directions(available_pos).is_empty(): 
			return available_pos
	for x in grid_size.x:
		for y in grid_size.y:
			var available_pos = Vector2(x,y)
			if get_circle_color(available_pos) == -1 && !get_available_directions(available_pos).is_empty(): 
				return available_pos
	printerr("Error, couldn't find an adequate candidate")
	return -Vector2.ONE

func get_available_directions(pos) -> Array[Vector2]:
	var result:Array[Vector2] = []
	for x in [-1, 1]:
		for y in [-1, 1]:
			var new_pos:Vector2 = pos + Vector2(x,y)
			# If is valid
			if pos != new_pos && \
				new_pos == new_pos.clamp(Vector2.ZERO, grid_size - Vector2.ONE) && \
				get_circle_color(new_pos) == -1: 
					result.append(new_pos)
	if result.is_empty():
		for x in [-1, 1]:
			for y in [true, false]:
				var new_pos:Vector2 = pos + Vector2(x,0)
				if y: new_pos = pos + Vector2(0,x)
				
				# If is valid
				if pos != new_pos && \
					new_pos == new_pos.clamp(Vector2.ZERO, grid_size - Vector2.ONE) && \
					get_circle_color(new_pos) == -1: 
						result.append(new_pos)
	return result

func get_random_end_circle(start_circle:Vector2) -> Vector2:
	var pos:Vector2 = start_circle
	for i in range(max_path_length):
		var available_dirs:Array[Vector2] = get_available_directions(pos)
		if available_dirs.is_empty(): return pos
		pos = available_dirs.pick_random()
		set_circle_color(pos, -2)
	return pos

func remove_temp_marks():
	for x in grid_size.x:
		for y in grid_size.y:
			var pos = Vector2(x,y)
			if get_circle_color(pos) == -2: 
				set_circle_color(pos, -1)

func _draw() -> void:
	# Debugging stuff:
	"
	for x in grid_size.x:
		for y in grid_size.y:
			draw_circle(get_screen_pos_centered(Vector2(x,y)), circle_size/2, Color.WEB_GRAY)
	"

func _process(_delta: float) -> void:
	if current_state == States.Idle:
		idle_handler()
	elif current_state == States.CableSelected:
		cable_selected_handler()

func get_circle_pos(pos:Vector2)->Vector2:
	pos = clamp(pos, Vector2.ZERO, size)
	var circle_pos = round((pos - cell_size/2)/cell_size)
	if (circle_pos*cell_size + cell_size/2).distance_squared_to(pos) <= (circle_size/2)**2 && \
		circle_pos.x < grid_size.x && circle_pos.y < grid_size.y:
		return circle_pos
	return -Vector2.ONE

func get_screen_pos(circle_pos:Vector2)->Vector2:
	return cell_size * circle_pos + border_size/2

func get_screen_pos_centered(circle_pos:Vector2)->Vector2:
	return get_screen_pos(circle_pos) + circle_size/2*Vector2.ONE

func get_circle_color(circle_pos:Vector2)->int:
	return button_colors.get(circle_pos, -1)

func set_circle_color(circle_pos:Vector2, circle_color:int):
	button_colors[circle_pos] = circle_color

func idle_handler():
	if Input.is_action_just_pressed("left click"):
		var circle_pos:Vector2 = get_circle_pos(get_local_mouse_position())
		if circle_pos != -Vector2.ONE:
			var circle_color = get_circle_color(circle_pos)
			if circle_color >= 0:
				current_state = States.CableSelected
				start_circle_pos = circle_pos
				current_circle_pos = circle_pos
				current_color = circle_color
				cables[current_color].add_point(get_screen_pos_centered(circle_pos))
				cables[current_color].add_point(get_local_mouse_position())
	
	if Input.is_action_just_pressed("right click"):
		var circle_pos:Vector2 = get_circle_pos(get_local_mouse_position())
		if circle_pos != -Vector2.ONE:
			var circle_color = get_circle_color(circle_pos)
			if circle_color < -1:
				unvalidate_path((-circle_color-2)%colors.size())
				completed_count -= 1

func cable_selected_handler():
	var current_cable:Line2D = cables[current_color]
	var line_length:int = current_cable.get_point_count()
	var pos:Vector2 = get_local_mouse_position()
	current_cable.set_point_position(line_length-1, pos)
	
	# Create path
	var circle_pos:Vector2 = get_circle_pos(get_local_mouse_position())
	if circle_pos != -Vector2.ONE && circle_pos.distance_squared_to(current_circle_pos) <= 2:
		var circle_color = get_circle_color(circle_pos)
		
		if circle_color == -1:
			current_cable.set_point_position(line_length-1, get_screen_pos_centered(circle_pos))
			current_cable.add_point(get_local_mouse_position())
			current_circle_pos = circle_pos
			
			images[circle_pos.x][circle_pos.y].modulate = colors[current_color]
			set_circle_color(circle_pos, -2-current_color)
		
		elif circle_color == current_color && start_circle_pos != circle_pos:
			current_cable.set_point_position(line_length-1, get_screen_pos_centered(circle_pos))
			validate_path(current_color)
			current_state = States.Idle
	
	if Input.is_action_just_released("left click"):
		unvalidate_path(current_color)
		current_state = States.Idle

func validate_path(color_index:int):
	var current_cable:Line2D = cables[color_index]
	var line_length:int = current_cable.get_point_count()
	for i in [0, line_length-1]:
		var circle_pos:Vector2 = get_circle_pos(current_cable.get_point_position(i))
		set_circle_color(circle_pos, -2-colors.size()-color_index)
	completed_count += 1
	
	if completed_count >= color_count:
		completed.emit()

func unvalidate_path(color_index:int):
	var current_cable:Line2D = cables[color_index]
	for pos in current_cable.points:
		var circle_pos:Vector2 = get_circle_pos(pos)
		var circle_color:int = get_circle_color(circle_pos)
		if circle_color == -2-color_index:
			set_circle_color(circle_pos, -1)
			images[circle_pos.x][circle_pos.y].modulate = unselected_color
		elif circle_color == -2-colors.size()-color_index:
			set_circle_color(circle_pos, color_index)
	current_cable.clear_points()
