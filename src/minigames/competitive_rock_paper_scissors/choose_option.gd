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
		 
func roll_players(choices): # c'est une pondération pas des valeurs entre 0 et 1
	add_theme_constant_override("separation", separation) 
	for i in choices : #On génère un nombre de boutons correspondant à la var en export
		var instance = ButtonScene.instantiate()
		match i : 
			Choice.ROCK : 
				instance.set_texture(rock_tex)
			Choice.PAPER : 
				instance.set_texture(paper_tex)
			Choice.SCISSORS : 
				instance.set_texture(scissors_tex)
		var btn = instance.get_node("TextureButton")
		btn.pressed.connect(update_player_choice.bind(i))
		instance.set_choice(i)
		add_child(instance)
	
func update_player_choice(choice):
	PlayerHasChosen.emit(choice)
	
func clear():
	for child in get_children():
		child.free()
