class_name RPS_button extends Node2D

@export var scale_rate:float = 1.2

var my_choice:RPS.Choice


func set_choice(choice:RPS.Choice) -> void :
	var my_choice = choice

func set_texture(texture:Texture):
	$TextureButton.texture_normal = texture
	
	

func setup_signals():
	pass


func _on_area_2d_mouse_entered():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "scale", Vector2.ONE*scale_rate, 0.2)


func _on_area_2d_mouse_exited():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
