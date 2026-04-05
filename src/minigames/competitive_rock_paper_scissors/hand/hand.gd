class_name hand extends TextureRect

@export var starting_rotation:int = -140
@export var final_rotation:int = -225


@export var scissors_tex:Texture
@export var rock_tex:Texture
@export var paper_tex:Texture

signal handAnimation


func get_hand_tip() : 
	return $HandTip
	
	
func rotate_hand(rotation_dest):
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", rotation_dest, 0.5)
	return tween
	
	
func _ready():
	rotation_degrees = starting_rotation
	pass


func draw_opponent_card(card:PackedScene, choice) : 
	



	rotation_degrees = starting_rotation
	await rotate_hand(final_rotation).finished
	
	var instance = card.instantiate()
	
	match choice : 
		RPS.Choice.ROCK : 
			instance.set_texture(rock_tex)
		RPS.Choice.PAPER : 
			instance.set_texture(paper_tex)
		RPS.Choice.SCISSORS : 
			instance.set_texture(scissors_tex)
	
	get_hand_tip().add_child(instance)
	
	await rotate_hand(starting_rotation).finished
	handAnimation.emit()
	



func clear():
	for child in get_hand_tip().get_children():
		child.free()
