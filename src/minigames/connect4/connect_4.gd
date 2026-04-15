extends Minigame

const PLAYER_COUNT = 2

enum Playstyles {
	RANDOM = 0,
	NORMAL = 1,
	HARD = 2,
}

signal win()
signal lose()
signal tie()

@export var board_size:Vector2 = Vector2(7,6)
@export var line_size:int = 4

@export var columns_texture:Texture2D = null
@export var columns_hovered_texture:Texture2D = null
@export var player_textures:Array[Texture2D] = [null, null]
@export var fall_max_duration:float = 0.5
@export var margin:Vector2 = Vector2(10,10)
@export_range(0,PLAYER_COUNT-1) var player_game_turn:int = 0

@export var computer_playstyle:Playstyles

# Game descriptors
@onready var columns_container:HBoxContainer = $GameContainer/ColumnContainer
@onready var game_container:MarginContainer = $GameContainer
var columns:Array[TextureRect]
var values_matrix:Array[Array]

var currently_hovered_column:int = -1
var current_player:int = 0
var is_in_animation:bool = false
var turn:int = 0
var game_finished:bool = false
var has_winner:bool = false

# Labels'n stuff
@onready var tie_label:Label = $TieLabel
@onready var win_label:Label = $WinLabel
@onready var lose_label:Label = $LoseLabel

# Visual stuff
var cell_size:Vector2

### Init Methods ###
func _ready() -> void:
	super()
	
	columns_container.add_theme_constant_override("separation", int(margin.x))
	for x in int(board_size.x):
		var texture_rect:TextureRect = create_empty_texture_rect(x)
		columns.append(texture_rect)
		columns_container.add_child(texture_rect)
		
		values_matrix.append([])
		for y in int(board_size.y):
			values_matrix[x].append(-1)
	
	for label:Label in [win_label, lose_label, tie_label]:
		label.scale = Vector2.ZERO
	
	if current_player != player_game_turn: computer_play()
	
	await get_tree().process_frame
	cell_size.x = columns[0].size.x
	cell_size.y = columns[0].size.y / board_size.y - margin.y

func create_empty_texture_rect(posX:int) -> TextureRect:
	var texture_rect:TextureRect = TextureRect.new()
	texture_rect.texture = columns_texture
	texture_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	texture_rect.mouse_entered.connect(on_mouse_entered_texture_rect.bind(posX))
	texture_rect.mouse_exited.connect(on_mouse_exited_texture_rect.bind(posX))
	
	return texture_rect

func create_empty_player_piece(player:int, posX:int) -> TextureRect:
	var texture_rect:TextureRect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.size = cell_size
	texture_rect.position = columns[posX].global_position
	texture_rect.position.y -= cell_size.y
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_rect.texture = player_textures[player]
	texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	return texture_rect

### Input Handling Methods ###
func _process(_delta: float) -> void:
	if game_finished || is_in_animation: return
	
	if Input.is_action_just_pressed("left click") && current_player == player_game_turn && \
			currently_hovered_column != -1 && !is_in_animation:
		await play(currently_hovered_column)
		if !game_finished: computer_play()

func on_mouse_entered_texture_rect(x:int):
	if values_matrix[x][-1] == -1 && current_player == player_game_turn && !game_finished && !is_in_animation:
		columns[x].texture = columns_hovered_texture
		currently_hovered_column = x

func on_mouse_exited_texture_rect(x:int):
	columns[x].texture = columns_texture
	currently_hovered_column = -1

func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)

### Game Handling Methods ###
func is_valid(x:int):
	return 0 <= x && x < board_size.x

func is_valid_pos(pos:Vector2):
	return 0 <= pos.x && pos.x < board_size.x &&\
		0 <= pos.y && pos.y < board_size.y

func get_unoccupied_line(x:int, board:Array[Array]=values_matrix) -> int:
	var y:int = 0
	while y < board_size.y && board[x][y] != -1: y+=1
	return y

func play(x:int):
	if !is_valid(x) || values_matrix[x][-1] != -1: return
	
	var y:int = get_unoccupied_line(x)
	values_matrix[x][y] = current_player
	turn += 1
	
	await place_animation(x,y)
	
	end_check(Vector2(x,y), current_player)
	current_player = (current_player + 1)%PLAYER_COUNT

func place_animation(x:int,y:int) -> void:
	var piece:TextureRect = create_empty_player_piece(current_player, x)
	var final_y:float = piece.position.y + cell_size.y*(board_size.y - y) + margin.y*(board_size.y - y)
	add_child(piece)
	
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(piece, "position:y", final_y, fall_max_duration)
	
	await tween.finished

func end_check(last_move:Vector2, player:int):
	if win_check(last_move, player):
		game_finished = true
		has_winner = true
	
	elif turn >= board_size.x * board_size.y:
		game_finished = true
		has_winner = false
	
	# Animations
	if game_finished:
		var label:Label = tie_label
		var end_signal:Signal = tie
		if has_winner:
			label = win_label if player == player_game_turn else lose_label
			end_signal = win if player == player_game_turn else lose
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(label, "scale", Vector2.ONE, 0.5)
		tween.tween_interval(2)
		tween.tween_callback(end_signal.emit)
		tween.tween_callback(exit)

func win_check(pos:Vector2, player:int, board:Array[Array]=values_matrix) -> bool:
	return direction_win_check(pos, player, Vector2(1,0), board) ||\
		direction_win_check(pos, player, Vector2(0,1), board) ||\
		direction_win_check(pos, player, Vector2(1,1), board) ||\
		direction_win_check(pos, player, Vector2(1,-1), board)

func direction_win_check(pos:Vector2, player:int, direction:Vector2, board:Array[Array]=values_matrix) -> bool:
	if board[pos.x][pos.y] == player:
		return 1 + direction_alignment_count(pos-direction, player, -direction, board) + direction_alignment_count(pos+direction, player, direction, board) >= line_size
	return 0 >= line_size

func direction_alignment_count(pos:Vector2, player:int, direction:Vector2, board:Array[Array]=values_matrix) -> int:
	var count:int = 0
	while is_valid_pos(pos) && board[pos.x][pos.y] == player: 
		count += 1
		pos += direction
	return count

### Computer Play ###
func get_available_moves(board:Array[Array]=values_matrix) -> Array[int]:
	var result:Array[int] = []
	for x in int(board_size.x):
		if board[x][-1] == -1: result.append(x)
	return result

func computer_play():
	match computer_playstyle:
		(Playstyles.RANDOM):
			computer_random_play()
		(Playstyles.NORMAL):
			computer_best_move(3)
		(Playstyles.HARD):
			computer_best_move(6)

func computer_random_play():
	play(get_available_moves().pick_random())

func computer_best_move(depth:int):
	depth = min(depth, board_size.x * board_size.y - turn)
	
	var beta:int = -depth-1
	var alpha:int = depth+1
	
	var best_moves:Array[int] = []
	var move_valuation:int = beta
	var next_player:int = (current_player + 1)%PLAYER_COUNT
	
	for x in get_available_moves():
		var board:Array[Array] = values_matrix.duplicate(true)
		var y = get_unoccupied_line(x, board)
		board[x][y] = current_player
		if win_check(Vector2(x,y), current_player, board): 
			best_moves = [x]
			move_valuation = depth
			break
		
		var valuation = -computer_negamax_eval(board, next_player, depth-1, -beta, -alpha)
		if valuation > move_valuation:
			best_moves = [x]
			beta = move_valuation
			move_valuation = valuation
		elif valuation == move_valuation:
			best_moves.append(x)
	play(best_moves.pick_random())

func computer_negamax_eval(board, player, depth, alpha, beta) -> int:
	if depth <= 0: return 0
	
	var best_valuation:int = -depth-1
	var next_player:int = (player + 1)%PLAYER_COUNT
	
	for x in get_available_moves(board):
		var new_board:Array[Array] = board.duplicate(true)
		var y = get_unoccupied_line(x, new_board)
		new_board[x][y] = player
		if win_check(Vector2(x,y), player, new_board): 
			best_valuation = depth
			break
		
		var valuation = -computer_negamax_eval(new_board, next_player, depth-1, -beta, -alpha)
		best_valuation = max(best_valuation, valuation)
		beta = max(best_valuation, beta)
		if alpha <= beta: 
			break
	
	return best_valuation
