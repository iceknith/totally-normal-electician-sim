extends AnimationPlayer


func _ready():
	setup_signals()
	
func setup_signals():
	GlobalVars.playFinalCutscene.connect(playCutscene)
	
func playCutscene():
	play("FinalCinematic")
	
