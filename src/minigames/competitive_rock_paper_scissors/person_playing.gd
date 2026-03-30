extends Node2D


enum Choice 
{
	ROCK,
	PAPER,
	SCISSORS,
	NOTHING
}

enum personPlaying
{
	STANLEY, # stanley chooses at random
	WILLY, # willy choisit celui dont il y a le moins restants
	BILLY # billy commence toujours avec pierre s'il peut, ensuite papier, puis ciseaux et après le premier round copie le 
}


#func generate_opponent_choice(opponent_choices, opponent, choice_per_round):
	#if opponent_choices.is_empty():
		#return null
	#var opponent_choice
	#match opponent : 
		#personPlaying.STANLEY : 
			#opponent_choice = opponent_choices[randi_range(0,choice_per_round -1)]
		#personPlaying.WILLY : 
			#var choicesNumber = [null, null, null]
			#choicesNumber[Choice.ROCK] = current_rock_number
			#choicesNumber[Choice.PAPER] = current_paper_number
			#choicesNumber[Choice.SCISSORS] = current_scissors_number
			#var min_value:int 
			#var min_index:Choice
			#for i in range(choicesNumber.size()):
				#if choicesNumber[i] < min_value:
					#min_value = choicesNumber[i]
					#min_index = i
	#return opponent_choice
				#
