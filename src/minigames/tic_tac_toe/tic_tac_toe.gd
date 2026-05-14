extends Minigame

const PLAYER_COUNT = 2

enum Playstyles {
	RANDOM = 0,
	NORMAL = 1,
	HARD = 2,
	IMPOSSIBLE = 3,
}

signal win()
signal lose()
signal tie()

@export var board_size:Vector2 = Vector2(3,3)
@export var line_size:int = 3

@export var empty_texture:Texture2D = null
@export var empty_hovered_texture:Texture2D = null
@export var player_textures:Array[Texture2D] = [null, null]
@export var margin:Vector2 = Vector2(10,10)
@export_range(0,PLAYER_COUNT-1) var player_game_turn:int = 0

@export var computer_playstyle:Playstyles

# Game descriptors
@onready var texture_container:VBoxContainer = $TextureMarginContainer/TextureContainer
var texture_rect_matrix:Array[Array]
var values_matrix:Array[Array]

var currently_hovered_rect:Vector2 = -Vector2.ONE
var current_player:int = 0
var turn:int = 0
var game_finished:bool = false
var has_winner:bool = false

# Labels'n stuff
@onready var tie_label:Label = $TieLabel
@onready var win_label:Label = $WinLabel
@onready var lose_label:Label = $LoseLabel

### Init Methods ###
func _ready() -> void:
	super()
	
	texture_container.add_theme_constant_override("separation", int(margin.y))
	
	for x in int(board_size.x):
		var line_container:HBoxContainer = create_empty_line_container()
		texture_rect_matrix.append([])
		values_matrix.append([])
		texture_container.add_child(line_container)
		for y in int(board_size.y):
			var texture_rect:TextureRect = create_empty_texture_rect(x,y)
			texture_rect_matrix[x].append(texture_rect)
			values_matrix[x].append(-1)
			line_container.add_child(texture_rect)
	
	for label:Label in [win_label, lose_label, tie_label]:
		label.scale = Vector2.ZERO
	
	if current_player != player_game_turn: computer_play()

func create_empty_line_container() -> HBoxContainer:
	var line_container:HBoxContainer = HBoxContainer.new()
	line_container.alignment = BoxContainer.ALIGNMENT_CENTER
	line_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	line_container.add_theme_constant_override("separation", int(margin.x))
	return line_container

func create_empty_texture_rect(posX:int, posY:int) -> TextureRect:
	var texture_rect:TextureRect = TextureRect.new()
	texture_rect.texture = empty_texture
	texture_rect.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	texture_rect.mouse_entered.connect(on_mouse_entered_texture_rect.bind(posX, posY))
	texture_rect.mouse_exited.connect(on_mouse_exited_texture_rect.bind(posX, posY))
	
	return texture_rect

### Input Handling Methods ###
func _process(_delta: float) -> void:
	if game_finished: return
	
	if Input.is_action_just_pressed("left click") && current_player == player_game_turn && \
			currently_hovered_rect != -Vector2.ONE:
		play(currently_hovered_rect)
		if !game_finished: computer_play()

func on_mouse_entered_texture_rect(x:int, y:int):
	if values_matrix[x][y] == -1 && current_player == player_game_turn && !game_finished:
		texture_rect_matrix[x][y].texture = empty_hovered_texture
		currently_hovered_rect = Vector2(x,y)

func on_mouse_exited_texture_rect(x:int, y:int):
	if values_matrix[x][y] == -1 && current_player == player_game_turn && !game_finished:
		texture_rect_matrix[x][y].texture = empty_texture
		currently_hovered_rect = -Vector2.ONE

func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)

### Game Handling Methods ###
func is_valid(pos:Vector2):
	return 0 <= pos.x && pos.x < board_size.x &&\
		0 <= pos.y && pos.y < board_size.y

func play(pos:Vector2):
	if !is_valid(pos) || values_matrix[pos.x][pos.y] != -1: return
	
	texture_rect_matrix[pos.x][pos.y].texture = player_textures[current_player]
	values_matrix[pos.x][pos.y] = current_player
	turn += 1
	end_check(pos, current_player)
	current_player = (current_player + 1)%PLAYER_COUNT

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
	while is_valid(pos) && board[pos.x][pos.y] == player: 
		count += 1
		pos += direction
	return count

### Computer Play ###
func get_available_moves(board:Array[Array]=values_matrix) -> Array[Vector2]:
	var result:Array[Vector2] = []
	for x in int(board_size.x):
		for y in int(board_size.y):
			if board[x][y] == -1: 
				result.append(Vector2(x,y))
	return result

func computer_play():
	match computer_playstyle:
		(Playstyles.RANDOM):
			computer_random_play()
		(Playstyles.NORMAL):
			computer_best_move(1)
		(Playstyles.HARD):
			computer_best_move(2)
		(Playstyles.IMPOSSIBLE):
			computer_best_move(9)

func computer_random_play():
	play(get_available_moves().pick_random())

func computer_best_move(depth:int):
	depth = min(depth, board_size.x * board_size.y - turn)
	
	var beta:int = -depth-1
	var alpha:int = depth+1
	
	var best_moves:Array[Vector2] = []
	var move_valuation:int = beta
	var next_player:int = (current_player + 1)%PLAYER_COUNT
	
	for pos in get_available_moves():
		var board:Array[Array] = values_matrix.duplicate(true)
		board[pos.x][pos.y] = current_player
		if win_check(pos, current_player, board): 
			best_moves = [pos]
			move_valuation = depth
			break
		
		var valuation = -computer_negamax_eval(board, next_player, depth-1, -beta, -alpha)
		if valuation > move_valuation:
			best_moves = [pos]
			beta = move_valuation
			move_valuation = valuation
		elif valuation == move_valuation:
			best_moves.append(pos)
	
	play(best_moves.pick_random())

func computer_negamax_eval(board, player, depth, alpha, beta) -> int:
	if depth <= 0: return 0
	
	var best_valuation:int = -depth-1
	var next_player:int = (player + 1)%PLAYER_COUNT
	
	for pos in get_available_moves(board):
		var new_board:Array[Array] = board.duplicate(true)
		new_board[pos.x][pos.y] = player
		if win_check(pos, player, new_board): 
			best_valuation = depth
			break
		
		var valuation = -computer_negamax_eval(new_board, next_player, depth-1, -alpha, -beta)
		best_valuation = max(best_valuation, valuation)
		beta = max(best_valuation, beta)
		if alpha <= beta: 
			break
	
	return best_valuation
