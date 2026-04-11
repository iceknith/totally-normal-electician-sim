class_name ElectricianMinigame extends Minigame

enum Stages {
	TutorialWires = 0,
	TutorialMovingCircle = 1,
	TutorialTiming = 2,
	FullGame = 3
}

signal win

@onready var cable_section:Node
@onready var timing_section:Node = $MarginContainer/GamesContainer/TimingContainer/TimingSection
@onready var moving_section:Node = $MarginContainer/GamesContainer/MovingContainer/MovingSection
@onready var cable_validated_label:Label = $MarginContainer/CableValidated
@onready var win_label:Label = $WinLabel
@onready var yay_label:Label = $YayLabel
@onready var lose_label:Label = $Loselabel
@onready var info_label:Label = $InfoContainer/MarginContainer/InfoLabel
@onready var info_container:Container = $InfoContainer

@onready var stage:Stages = GlobalVars.electrician_minigame_current_stage
@export var tutorialTexts:Dictionary[Stages, String] = {
	Stages.TutorialWires : "Connectez les fils de la même couleur avec [clic gauche]\n-\nDéconnectez les fils avec [clic droit]\n-\nIl est possible de croiser les fils en diagonale",
	Stages.TutorialMovingCircle : "Faites attention à ne pas déclencher un court circuit !\n-\nPour celà, restez dans le grand cercle en vous déplaçant avec vos contrôles de mouvement.",
	Stages.TutorialTiming : "Attention à ne pas vous éléctriser !\n-\nPour celà, appuyez sur [Espace] lorsque le cube rouge devient rose."
}

@export var cables_required:int = 100
var cables_validated:int:
	set(new_val):
		cables_validated = new_val
		cable_validated_label.text = "%d/%d" % [cables_validated, cables_required]

func _ready() -> void:
	super()
	cables_validated = 0
	connect_signals()
	win_label.scale = Vector2.ZERO
	lose_label.scale = Vector2.ZERO
	yay_label.scale = Vector2.ZERO
	info_container.scale = Vector2.ZERO
	
	await get_tree().process_frame
	reset_cable()
	init_stage()

func init_stage() -> void:
	if stage == Stages.FullGame: return
	
	info_label.text = tutorialTexts[stage]
	
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(info_container, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(3)
	
	match stage:
		Stages.TutorialWires:
			$MarginContainer/GamesContainer/TimingContainer.queue_free()
			$MarginContainer/GamesContainer/MovingContainer.queue_free()
			cable_section.process_mode = Node.PROCESS_MODE_DISABLED
			tween.tween_callback(func(): cable_section.process_mode = Node.PROCESS_MODE_INHERIT)
		Stages.TutorialMovingCircle:
			$MarginContainer/GamesContainer/TimingContainer.queue_free()
			for section in [cable_section, moving_section]:
				print(section)
				section.process_mode = Node.PROCESS_MODE_DISABLED
				tween.tween_callback(func(): section.process_mode = Node.PROCESS_MODE_INHERIT)
		Stages.TutorialTiming:
			for section in [cable_section, moving_section, timing_section]:
				section.process_mode = Node.PROCESS_MODE_DISABLED
				tween.tween_callback(func(): section.process_mode = Node.PROCESS_MODE_INHERIT)
	
	tween.tween_property(info_container, "scale", Vector2.ZERO, 0.2)
	

func connect_signals() -> void:
	#cable_section.completed.connect(on_cable_validated)
	timing_section.failed.connect(on_minigame_failed)
	moving_section.failed.connect(on_minigame_failed)
	$MarginContainer/Exit.pressed.connect(exit)

func on_cable_validated():
	cables_validated += 1
	
	if cables_validated >= cables_required:
		end_game()
	else:
		cable_section.process_mode = Node.PROCESS_MODE_DISABLED
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
		tween.tween_property(yay_label, "scale", Vector2.ONE, 0.2)
		tween.tween_interval(0.3)
		tween.tween_callback(reset_cable)
		tween.tween_property(yay_label, "scale", Vector2.ZERO, 0.2)

func on_minigame_failed():
	reset_cable()
	if timing_section: timing_section.reset()
	if moving_section: moving_section.reset()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(lose_label, "scale", Vector2.ONE, 0.3)
	tween.tween_interval(0.3)
	tween.tween_property(lose_label, "scale", Vector2.ZERO, 0.5)

func reset_cable():
	if cable_section: cable_section.queue_free()
	cable_section = load("res://src/minigames/electician_minigame/cableSection.tscn").instantiate()
	get_node("MarginContainer/GamesContainer/PanelContainer/SubViewportContainer/CableViewport/Container").add_child(cable_section)
	cable_section.completed.connect(on_cable_validated)

func end_game():
	if cable_section: cable_section.process_mode = Node.PROCESS_MODE_DISABLED
	if moving_section: moving_section.process_mode = Node.PROCESS_MODE_DISABLED
	if timing_section: timing_section.process_mode = Node.PROCESS_MODE_DISABLED
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(win_label, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(2)
	tween.tween_callback(win.emit)
	tween.tween_callback(exit)

func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.REMOVE_MINIGAME)
