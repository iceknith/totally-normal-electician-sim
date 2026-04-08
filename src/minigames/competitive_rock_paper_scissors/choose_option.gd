extends Node2D


@export var scissors_tex:Texture
@export var rock_tex:Texture
@export var paper_tex:Texture
@export var offset:float
@export var number_of_buttons:int
@export var shuffle_time:float
@export var curve:Curve


@export var max_rotation:int = 5

var final_pos
var can_generate_card = true


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
		 
func roll_players(choices, handPile, drawPile, playPile): 

	var n = len(choices)
		
	var instances = []
	var nb_of_cards = len(choices)

	var total_width = (nb_of_cards - 1) * offset
	var start_x = - total_width / 2.0
	var j = 0
	for i in choices : #On génère un nombre de boutons correspondant à la var en export
		if can_generate_card == false : 
			return
		var tween = create_tween()
		var start_pos = drawPile.global_position 
		var final_pos = handPile.global_position 
		print(final_pos)
		final_pos.x -= floor(n/2 - j)*offset
		var instance = ButtonScene.instantiate()
		
		instance.set_choice(i)
		handPile.add_child(instance)

		
		match i : 
			RPS.Choice.ROCK : 
				instance.set_texture(rock_tex)
			RPS.Choice.PAPER : 
				instance.set_texture(paper_tex)
			RPS.Choice.SCISSORS : 
				instance.set_texture(scissors_tex)
		#var min_size = instance.get_combined_minimum_size()
		var btn = instance.get_node("TextureButton")
		manage_rotation(choices, instance, j)
		j +=1
		btn.pressed.connect(update_player_choice.bind(i, self))

		instance.global_position = start_pos #la position est askip recalculé en utilisant add_child
		
		
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(instance, "global_position", final_pos, shuffle_time)
		await tween.finished
		await get_tree().create_timer(0.5).timeout
		instances.append(instance)

		

		


func manage_rotation(choices, instance, card_nb):
	var nb_of_cards = len(choices)
 
	var t = card_nb / float(nb_of_cards - 1) if nb_of_cards > 1 else 0.5
	instance.rotation_degrees = curve.sample(t) * max_rotation

	

func get_hand_tip() : 
	return $handTip

func set_can_generate_card(value:bool):
	can_generate_card = value

func update_player_choice(choice, selected_instance):
	clear_non_choice(selected_instance)
	PlayerHasChosen.emit(choice)
	can_generate_card = false
	

func clear_non_choice(selected_instance):
	for child in selected_instance.get_children():
		if child != selected_instance:
			child.queue_free()
