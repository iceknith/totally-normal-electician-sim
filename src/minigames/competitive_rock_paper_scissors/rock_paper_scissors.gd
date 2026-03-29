extends Control

@onready var chooseOption:Node =%ChooseOption
@onready var player1_choice_label:Node =$MarginContainer/VBoxContainer/PanelContainer/VBoxContainer/PanelContainer/Choice
@onready var rolling_sprite:Node = %RollSprite

@onready var win_label:Label = $WinLabel
@onready var yay_label:Label = $YayLabel
@onready var lose_label:Label = $Loselabel

@export var number_of_rounds  = 3



enum Choice 
{
	ROCK,
	PAPER,
	SCISSORS
}

enum Result{
	PLAYER_WIN,
	OPPONENT_WIN,
	DRAW
}

#player and opponent choice
var has_player_chosen:bool
var player_choice
var opponent_choice

var beats = {
	Choice.ROCK: Choice.SCISSORS,
	Choice.PAPER: Choice.ROCK,
	Choice.SCISSORS: Choice.PAPER
}



func _ready():
	yay_label.scale = Vector2.ZERO
	lose_label.scale = Vector2.ZERO
	chooseOption.roll_players()
	setup_signals()
	
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
			

func _on_confirm_button_pressed():
	if has_player_chosen : 
		opponent_choice = generate_opponent_choice()
		rolling_sprite.roll_sprites(opponent_choice)

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
	pass
func draw():
	pass
	
func player_wins():
	yay_animation()
	


	
func player_loses():
	lose_animation()
	
	
func get_result(choice1:int, choice2:int) -> int:
	if choice1 == choice2:
		return Result.DRAW
	if beats[choice1] == choice2:
		return Result.PLAYER_WIN
	return Result.OPPONENT_WIN
	
	
func generate_opponent_choice():
	return randi_range(0, 2)
	
func yay_animation():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(yay_label, "scale", Vector2.ONE, 0.2)
	tween.tween_interval(0.3)
	tween.tween_property(yay_label, "scale", Vector2.ZERO, 0.2)
	
func lose_animation():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(lose_label, "scale", Vector2.ONE, 0.3)
	tween.tween_interval(0.3)
	tween.tween_property(lose_label, "scale", Vector2.ZERO, 0.5)
	
