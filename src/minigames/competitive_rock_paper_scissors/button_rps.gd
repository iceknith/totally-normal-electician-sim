class_name RPS_button extends Node2D

enum Choice{
	Rock,
	Paper,
	Scissors
}

@export var scale_rate:float = 1.2

var my_choice:Choice = Choice.Rock


func set_choice(choice:Choice) -> void :
	my_choice = choice

func set_texture(texture:Texture):
	$TextureButton.texture_normal = texture
	
	
func play_flip_animation():
	$AnimationPlayer.play("flip")
	return $AnimationPlayer.animation_finished
	

func setup_signals():
	pass


func _on_texture_button_pressed():
	pass # Replace with function body.


func _on_area_2d_mouse_entered():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "scale", Vector2.ONE*scale_rate, 0.2)
	print("mouse entered")


	



	


func _on_area_2d_mouse_exited():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
