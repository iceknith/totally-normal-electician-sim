class_name ArcadeFullGame extends Minigame


var opponent:JoManager.opponent = JoManager.opponent.LittleJo
var play_tutorial = false

func _enter_tree() -> void:
	$Jeu/RenduJeu/Arena.opponent_preset = opponent
	$Jeu/RenduJeu/Arena.play_tutorial = play_tutorial
