class_name RPS_button extends PanelContainer

enum Choice{
	Rock,
	Paper,
	Scissors
}

var my_choice:Choice = Choice.Rock

func set_choice(choice:Choice) -> void :
	my_choice = choice

func set_texture(texture:Texture):
	$TextureButton.texture_normal = texture
	
	

func setup_signals():
	pass


func _on_texture_button_pressed():
	pass # Replace with function body.
