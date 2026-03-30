extends Control

enum personPlaying
{
	STANLEY, # stanley chooses at random
	WILLY, # willy choisit celui dont il y a le moins restants
	BILLY # billy commence toujours avec pierre s'il peut, ensuite papier, puis ciseaux et après le premier round copie le 
}
enum Choice 
{
	ROCK,
	PAPER,
	SCISSORS,
	NOTHING
}

enum Result{
	PLAYER_WIN,
	OPPONENT_WIN,
	DRAW
}



@onready var chooseOption:Node =%ChooseOption
@onready var player1_choice_label:Node =$MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/PanelContainer/Choice
@onready var rolling_sprite:Node = %RollSprite
@onready var dice_table:Node = %TableDice
@onready var person_playing:Node = %PersonPlaying

@onready var yay_label:Label = $YayLabel
@onready var lose_label:Label = $Loselabel
@onready var draw_label:Label = $DrawLabel
@onready var win_label:Label = $EndGameLabel

@export var number_of_rounds:int  = 3
@export var points_to_win:int = 3
@export var choice_per_round:int = 3


@export var total_choice_number:int

var current_rock_number:int = 0
var current_paper_number:int = 0 
var current_scissors_number:int = 0

var choices:Array = []
var opponents_points:int = 0
var player_points:int = 0


@export var opponent:personPlaying = personPlaying.STANLEY




#player and opponent choice
var has_player_chosen:bool
var has_player_drawn:bool
var is_rolling:bool
var is_game_setup:bool


#the final choice of the player and their opponent
var player_choice:Choice
var opponent_choice:Choice
var last_player_choices = []


#the choice possibilities of the player and their opponent
var player_choices
var opponent_choices

var beats = {
	Choice.ROCK: Choice.SCISSORS,
	Choice.PAPER: Choice.ROCK,
	Choice.SCISSORS: Choice.PAPER
}

var current_numbers = {
	Choice.ROCK : 0,
	Choice.PAPER : 0,
	Choice.SCISSORS : 0
}



func _ready():
	yay_label.scale = Vector2.ZERO
	lose_label.scale = Vector2.ZERO
	draw_label.scale = Vector2.ZERO
	setup_signals()
	show_points()
	show_number_of_each()
	
func _process(delta):
	show_points()
	show_number_of_each()
	
	
func setup_signals():
	chooseOption.PlayerHasChosen.connect(update_player_choice)
	rolling_sprite.rolling_finished.connect(show_winner)
	
	
func update_player_choice(choice):
	has_player_chosen = true
	player_choice = choice
	match player_choice : 
		Choice.ROCK:
			player1_choice_label.text = "ROCK"
		Choice.PAPER:
			player1_choice_label.text = "PAPER"
		Choice.SCISSORS:
			player1_choice_label.text = "SCISSORS"
		Choice.NOTHING : 
			player1_choice_label.text = ""
			

func _on_confirm_button_pressed():
	if has_player_chosen and !is_rolling: 
		is_rolling = true
		opponent_choice = generate_opponent_choice()
		update_choice_stock(player_choice)
		update_choice_stock(opponent_choice)
		rolling_sprite.roll_sprites(opponent_choice)
		chooseOption.clear()

func show_winner():
	var winner = get_result(player_choice, opponent_choice)
	match winner :
		Result.DRAW : 
			draw()
		Result.PLAYER_WIN:
			player_wins()
		Result.OPPONENT_WIN : 
			player_loses()

func reset():
	choices = generate_shuffle_choice()
	player_choice = Choice.NOTHING
	opponent_choice = Choice.NOTHING
	has_player_drawn = false
	has_player_chosen = false
	is_rolling = false
	
func complete_reset():
	chooseOption.clear()
	has_player_drawn = false
	has_player_chosen = false
	is_rolling = false
	is_game_setup = false
	current_numbers[Choice.ROCK] = 0
	current_numbers[Choice.PAPER] = 0
	current_numbers[Choice.SCISSORS] = 0
	opponents_points = 0
	player_points = 0

	
	
func draw():
	await draw_animation().finished
	reset()
	
func player_wins():
	await yay_animation().finished
	player_points+=1
	reset()
	

	
func player_loses():
	await lose_animation().finished
	opponents_points+=1
	reset()
	
	
func get_result(choice1:int, choice2:int) -> int:
	if choice1 == choice2:
		return Result.DRAW
	if beats[choice1] == choice2:
		return Result.PLAYER_WIN
	return Result.OPPONENT_WIN
	
	
func generate_opponent_choice():
	if opponent_choices.is_empty():
		return null
	var opponent_choice:Choice
	match opponent : 
		personPlaying.STANLEY : 
			opponent_choice = opponent_choices[randi_range(0,choice_per_round -1)]
		personPlaying.WILLY : 
			var choices_number = [null, null, null]
			if (Choice.ROCK in opponent_choices) :choices_number[Choice.ROCK] = current_numbers[Choice.ROCK]
			if (Choice.PAPER in opponent_choices) : choices_number[Choice.PAPER] =  current_numbers[Choice.PAPER]
			if (Choice.SCISSORS  in opponent_choices) : choices_number[Choice.SCISSORS] =current_numbers[Choice.SCISSORS]
			
			print(opponent_choices)
			var min_index = opponent_choices[0]
			print("min index : ", min_index)
			for c in opponent_choices : 
				print("choice number : ", choices_number[c])
				print("current_numbers min index : ", current_numbers[min_index])
				print("c : ", c)
	
				if choices_number[c] <= current_numbers[min_index] : 
					min_index = c
					opponent_choice = c
				print("min index : ", min_index)
			
			
	return opponent_choice

func update_choice_stock(choice):
	current_numbers[choice] -= 1 

func yay_animation():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(yay_label, "scale", Vector2.ONE, 0.2)
	tween.tween_interval(0.3)
	tween.tween_property(yay_label, "scale", Vector2.ZERO, 0.2)
	return tween
	
func lose_animation():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(lose_label, "scale", Vector2.ONE, 0.3)
	tween.tween_interval(0.3)
	tween.tween_property(lose_label, "scale", Vector2.ZERO, 0.5)
	return tween
	
func draw_animation():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(draw_label, "scale", Vector2.ONE, 0.3)
	tween.tween_interval(0.3)
	tween.tween_property(draw_label, "scale", Vector2.ZERO, 0.5)
	return tween


func _on_roll_player_pressed():
	dice_table.reset_and_roll()


func _on_setup_button_pressed(): #setup la game définit le nombre de pierre papier et ciseaux qu'il y aura dans la game
	if !is_game_setup : 
		generate_choices()
		is_game_setup = true
		show_points()
		show_number_of_each()
	


func generate_choices(choice_number = total_choice_number): #génère les choix et les ajoute dans la liste
	for i in choice_number:
		var rand_choice = randi_range(0, 2)
		choices.append(rand_choice)
		current_numbers[rand_choice] +=1


func generate_shuffle_choice() -> Array: #regénère une liste à partir du nombre restant de choix de chacun
	var new_choices:Array = []
		# Ajouter les ROCK
	for i in range(current_numbers[Choice.ROCK]) :
		new_choices.append(Choice.ROCK)
	
	# Ajouter les PAPER
	for i in range(current_numbers[Choice.PAPER]) :
		new_choices.append(Choice.PAPER)
	
	# Ajouter les SCISSORS
	for i in range(current_numbers[Choice.SCISSORS]):
		new_choices.append(Choice.SCISSORS)
		
	# Mélanger
	new_choices.shuffle()
	return new_choices

func show_number_of_each():
	$MarginContainer/VBoxContainer/HBoxContainer2/Label.text = \
	"rocks = " + str(current_numbers[Choice.ROCK]) + \
	" papers = " + str(current_numbers[Choice.PAPER]) + \
	" scissors = " + str(current_numbers[Choice.SCISSORS])

func show_points():
	$MarginContainer/VBoxContainer/HBoxContainer2/showPoints.text = \
	"player points = " + str(player_points) + \
	" opponent points = " + str(opponents_points)
	
func _on_draw_button_pressed(): #si la game est setup et que le player a pas encore pioché ce tour, 
	if !has_player_drawn and is_game_setup: 
		player_choices = choices.slice(0, choice_per_round) #on prend le nombre de carte dont on a besoin par round
		opponent_choices = choices.slice(choice_per_round, choice_per_round*2)
		print(opponent_choices)
		chooseOption.roll_players(player_choices)
		has_player_drawn = true	
	
func won_game():
	pass

func _on_complete_reset_pressed():
	complete_reset()
	

func end_game():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(win_label, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(2)
	exit()

func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.SHOW_GAME3D)

	
	

	
	
	
