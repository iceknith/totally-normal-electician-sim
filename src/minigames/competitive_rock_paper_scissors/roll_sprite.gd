extends Control


@export var scissors_tex:Texture
@export var rock_tex:Texture
@export var paper_tex:Texture

@export var total_duration:float
@export var speed_curve:Curve
@export_range(0, 1, 0.01) var final_choice_delay

# you cant edit the speed curve and the bake resolution to change the rolling speed
var test_choice = 1
var texture_rect:TextureRect

signal rolling_finished

enum choice 
{
	ROCK,
	PAPER,
	SCISSORS
}

func _ready():
	setup_scene()

func roll_sprites(final_choice):
	var tex_list = [rock_tex, paper_tex, scissors_tex] #faut faire attention à ce que ça respect l'ordre de l'enum
	var tween = create_tween()
	var last_rerolled = -1
	var steps = speed_curve.bake_resolution
	
	var weights = []
	var total_weight = 0.0
	
	for i in range(steps): #on setup les weights de chaque frame
		var t = float(i) / max(steps - 1, 1)
		var speed = max(speed_curve.sample(t), 0.001) #si c'est 0 on a des frames infinis donc on évite
		var w = 1.0 / speed 
		weights.append(w)
		total_weight += w
	
	for i in range(steps):
		var randn = randi_range(0, 2)
		while (randn == last_rerolled) :
			randn = randi_range(0, 2)
		last_rerolled = randn
		
		tween.tween_callback(update_texture.bind(tex_list[randn]))
		
		var wait_time = total_duration * (weights[i] / total_weight)
		tween.tween_interval(wait_time)
		
	tween.tween_interval(final_choice_delay)
	tween.tween_callback(update_texture.bind(tex_list[final_choice]))
	await tween.finished
	rolling_finished.emit()
	
	
func setup_scene():
	texture_rect = TextureRect.new()
	add_child(texture_rect)	
	
func update_texture(texture:Texture):
	texture_rect.texture = texture
	
