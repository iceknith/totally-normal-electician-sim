class_name RPS extends Minigame

enum personPlaying
{
	STANLY, # stanley chooses at random
	WILLY, # willy choisit celui dont il y a le moins restants
	BILLY, # billy dans le premier round commence toujours par pierre < papier < ciseaux et après le premier round copie le 
	RAYLY
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
@onready var hand:Node = %Hand

@onready var hand_pile:Node =$HandPile
@onready var draw_pile:Node = $DrawPile
@onready var play_pile:Node = $PlayPile
@onready var person_playing:Node = %PersonPlaying


@onready var win_label:RichTextLabel = $EndGameLabel

@export var rounds_number:int  = 3
@export var points_to_win:int = 3
@export var choice_per_round:int = 3


@export var total_choice_number:int
@export var card_scene = load("res://src/minigames/competitive_rock_paper_scissors/RPS_button.tscn")

var choices:Array = []
var opponents_points:int = 0
var player_points:int = 0

var current_round_number = 0

@export var opponent:personPlaying = personPlaying.STANLY




#player and opponent choice
var has_player_chosen:bool
var has_player_drawn:bool
var is_rolling:bool
var has_game_started:bool


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

var current_total_choice_number = 0



func _ready():
	super()
	win_label.scale = Vector2.ZERO
	setup_signals()
	show_points()
	show_number_of_each()
	
func _process(delta):
	show_points()
	show_number_of_each()
	
	
func setup_signals():
	chooseOption.PlayerHasChosen.connect(update_player_choice)
	rolling_sprite.rolling_finished.connect(show_winner)
	hand.handAnimation.connect(show_winner)
	
	
	
func update_player_choice(choice):
	chooseOption.set_can_generate_card(false) 
	has_player_chosen = true
	player_choice = choice
	if has_player_chosen and !is_rolling: 
		is_rolling = true
		opponent_choice = generate_opponent_choice()
		print(opponent_choice)
		update_choice_stock(player_choice)
		last_player_choices.append(player_choice)
		update_choice_stock(opponent_choice)
		
		#ici faut faire draw l'opponent 
		hand.draw_opponent_card(card_scene, opponent_choice)
		clear()
		
	match player_choice : 
		Choice.ROCK:
			player1_choice_label.text = "ROCK"
		Choice.PAPER:
			player1_choice_label.text = "PAPER"
		Choice.SCISSORS:
			player1_choice_label.text = "SCISSORS"
		Choice.NOTHING : 
			player1_choice_label.text = ""

func update_current_total_choice_number():
	current_total_choice_number = current_numbers[Choice.ROCK] + current_numbers[Choice.SCISSORS] + current_numbers[Choice.PAPER]


func show_winner():

	current_round_number +=1
	var winner = get_result(player_choice, opponent_choice)
	update_current_total_choice_number()
	match winner :
		Result.DRAW : 
			await draw()
		Result.PLAYER_WIN:
			await player_wins()
		Result.OPPONENT_WIN : 
			await player_loses()
	if rounds_number == current_round_number : 
		end_game()
	elif player_points == points_to_win : 
		player_won_game()
	elif opponents_points == points_to_win : 
		opponent_won_game()
	elif current_total_choice_number < choice_per_round * 2 : 
		await text_animation(win_label, \
		 " [center] [wave amp = 512 freq = 24] [rainbow] Reshuffling !!!", \
		2).finished
		await generate_choices()
		draw_cards()
	else: 
		draw_cards()
	
func reset():
	choices = generate_shuffle_choice()
	player_choice = Choice.NOTHING
	opponent_choice = Choice.NOTHING
	has_player_drawn = false
	has_player_chosen = false
	is_rolling = false
	
func complete_reset():
	clear()
	has_player_drawn = false
	has_player_chosen = false
	is_rolling = false
	has_game_started = false
	current_numbers[Choice.ROCK] = 0
	current_numbers[Choice.PAPER] = 0
	current_numbers[Choice.SCISSORS] = 0
	opponents_points = 0
	player_points = 0

	
	
func draw():
	await text_animation(win_label, \
	"[center] Draw !" \
	, 0.7, Color.YELLOW).finished
	reset()
	
func player_wins():
	await text_animation(win_label, \
	"[center] Yaaaaay !" \
	, 0.7, Color.GREEN).finished
	player_points+=1
	reset()
	

	
func player_loses():
	await text_animation(win_label,\
	 "[center] Try again !" \
	, 1, Color.RED).finished
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
		personPlaying.STANLY : 
			opponent_choice = opponent_choices[randi_range(0,choice_per_round -1)]
		personPlaying.WILLY : #il choisit tjrs le moins 
			var choices_number = [null, null, null]
			if (Choice.ROCK in opponent_choices) :choices_number[Choice.ROCK] = current_numbers[Choice.ROCK]
			if (Choice.PAPER in opponent_choices) : choices_number[Choice.PAPER] =  current_numbers[Choice.PAPER]
			if (Choice.SCISSORS  in opponent_choices) : choices_number[Choice.SCISSORS] =current_numbers[Choice.SCISSORS]
		
			var min_index = opponent_choices[0]
			for c in opponent_choices : 
				if choices_number[c] <= current_numbers[min_index] : 
					min_index = c
					opponent_choice = c
		personPlaying.BILLY : 
			var copy_player:bool = false#Billy tries to copy the player last choices, if he cant he will choose randomly
			for i in opponent_choices : 
				if i in last_player_choices : 
					copy_player = true
			if copy_player : 
				opponent_choice = opponent_choices[randi_range(0,choice_per_round -1)]
			else :
				for i in last_player_choices : 
					var opponent_has_chosen = false
					for j in opponent_choices : 
						if i == j : 
							opponent_choice = j
							opponent_has_chosen = true
							break
					if opponent_has_chosen == true : 
						break

	return opponent_choice
	

func update_choice_stock(choice):
	current_numbers[choice] -= 1 


	

func text_animation(label: RichTextLabel, text: String, duration: float = 1, color:Color = Color.WHITE ):
	label.text = text
	label.modulate = color
	var tween = create_tween() #tween d'animation du texte
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	
	var appear_time = duration * 0.3
	var hold_time = duration * 0.4
	var disappear_time = duration * 0.3
	
	tween.tween_property(label, "scale", Vector2.ONE, appear_time)
	tween.tween_interval(hold_time)
	tween.tween_property(label, "scale", Vector2.ZERO, disappear_time)
	
	return tween
	
func end_game():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(win_label, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(2)
	exit()
	


func player_won_game(): #condition à executer si le player gagne la partie
	await text_animation(win_label, "You WON \n the GAME !!!!!", 1, Color.GREEN)
	exit()
	
func opponent_won_game(): #condition à executer si l'opponent gagne la partie
	await text_animation(win_label, "You WON \n the GAME !!!!!", 1, Color.RED)
	exit()
	
func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.SHOW_GAME3D)
	
	
	
func setup_game(): #setup de la game
	
	generate_choices()
	has_game_started = true
	show_points()
	show_number_of_each()


func generate_choices(choice_number = total_choice_number): #genere les choix
	current_numbers[Choice.ROCK] = 0
	current_numbers[Choice.PAPER] = 0
	current_numbers[Choice.SCISSORS] = 0
	choices.clear()
	clear()
	
	var min_each = choice_number / 6#on génère au minimum un quart de chaque 
	
	for i in min_each:
		choices.append(Choice.ROCK)
		choices.append(Choice.PAPER)
		choices.append(Choice.SCISSORS)
		
		current_numbers[Choice.ROCK] += 1
		current_numbers[Choice.PAPER] += 1
		current_numbers[Choice.SCISSORS] += 1
	
	while choices.size() < choice_number: #on complète
		var rand_choice = randi_range(0, 2)
		choices.append(rand_choice)
		current_numbers[rand_choice] += 1


func generate_shuffle_choice() -> Array: #regénère une liste à partir du nombre restant de choix de chacun
	var new_choices:Array = []
		# Ajouter les ROCK
	for i in range(current_numbers[Choice.ROCK]) :
		new_choices.append(Choice.ROCK)
	
	# Ajouter les PAPER
	for i in range(current_numbers[Choice.PAPER]) :
		new_choices.append(Choice.PAPER)
	
	# Ajouter etles SCISSORS
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
	"player points = " + str(player_points) + " \\ " + str(points_to_win) + \
	" opponent points = " + str(opponents_points) + " \\ " + str(points_to_win)

func draw_cards():
	if !has_player_drawn and has_game_started: 
		player_choice = Choice.NOTHING
		player_choices = choices.slice(0, choice_per_round) #on prend le nombre de carte dont on a besoin par round
		opponent_choices = choices.slice(choice_per_round, choice_per_round*2)
		chooseOption.set_can_generate_card(true)
		chooseOption.roll_players(player_choices, hand_pile, draw_pile, play_pile)
		has_player_drawn = true	

func won_game():
	pass

func _on_complete_reset_pressed():
	chooseOption.set_can_generate_card(false) #eivter de regénerer des cartes 
	complete_reset()
	

func _on_setup_button_pressed():
	if !has_game_started : 
		setup_game()
		draw_cards()

func clear(): 
	for child in hand_pile.get_children():
		child.free()
		
	
