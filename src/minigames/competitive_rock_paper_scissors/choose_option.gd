extends Control


@export var scissors_tex:Texture
@export var rock_tex:Texture
@export var paper_tex:Texture
@export var separation:float
@export var number_of_buttons:int

var ButtonScene:PackedScene = load("res://src/minigames/competitive_rock_paper_scissors/RPS_button.tscn")
var hbox = HBoxContainer.new()

enum Choice 
{
	ROCK,
	PAPER,
	SCISSORS
}


signal PlayerHasChosen(choice)


func _process(delta):
	pass
	
func _ready():
	pass
		 
func roll_players(rock_odds:int = 1, paper_odds:int = 1, scissors_odds:int = 1): # c'est une pondération pas des valeurs entre 0 et 1
	add_theme_constant_override("separation", separation) 
	for i in range(number_of_buttons) : #On génère un nombre de boutons correspondant à la var en export
		var random_n = randi_range(0, 2) # On génère un nombre random pour determiner si c'est pierre papier ou ciseau
		var instance = ButtonScene.instantiate()
		match random_n : 
			Choice.ROCK : 
				instance.set_texture(rock_tex)
			Choice.PAPER : 
				instance.set_texture(paper_tex)
			Choice.SCISSORS : 
				instance.set_texture(scissors_tex)
		var btn = instance.get_node("TextureButton")
		
		btn.pressed.connect(update_player_choice.bind(random_n))
		instance.set_choice(i)
		add_child(instance)
	
func update_player_choice(choice):
	PlayerHasChosen.emit(choice)
	
	
	
