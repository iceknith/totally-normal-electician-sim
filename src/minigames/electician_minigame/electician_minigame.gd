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
@onready var info_container:VBoxContainer = $InfoVboxContainer
@onready var info_label:Label = $InfoVboxContainer/InfoContainer/MarginContainer/InfoLabel
@onready var info_exit_button:Button = $InfoVboxContainer/Button

@onready var stage:Stages = GlobalVars.electrician_minigame_current_stage
@onready var tutorialTexts:Dictionary[Stages, String] = {
	Stages.TutorialWires : "Connect same color wires with [Left Click].\nDisconnect with [Right Click].\n-\nWires can cross in diagonal.",
	Stages.TutorialMovingCircle : "Be careful to not create a short circuit, by letting the screw and the wrench touch.\n-\nTo prevent that, move the Wrench with [$up$ $left$ $down$ $right$]",
	Stages.TutorialTiming : "Be careful not to electrify yourself, by letting the fuse touch the ground !\n-\nTo prevent that, press [$interact2$] when the fuse crosses the central line."
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
	info_exit_button.disabled = true
	info_exit_button.pressed.connect(hide_tutorial)
	
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(info_container, "scale", Vector2.ONE, 0.5)
	tween.tween_property(info_exit_button, "disabled", false, 0.01)
	
	match stage:
		Stages.TutorialWires:
			$MarginContainer/GamesContainer/TimingContainer.queue_free()
			$MarginContainer/GamesContainer/MovingContainer.queue_free()
			cable_section.process_mode = Node.PROCESS_MODE_DISABLED
		Stages.TutorialMovingCircle:
			$MarginContainer/GamesContainer/TimingContainer.queue_free()
			for section in [cable_section, moving_section]:
				section.process_mode = Node.PROCESS_MODE_DISABLED
		Stages.TutorialTiming:
			for section in [cable_section, moving_section, timing_section]:
				section.process_mode = Node.PROCESS_MODE_DISABLED
	
func hide_tutorial():
	var tween:Tween = create_tween()
	tween.tween_property(info_container, "scale", Vector2.ZERO, 0.2)
	
	for section in [cable_section, moving_section, timing_section]:
		if section: section.process_mode = Node.PROCESS_MODE_INHERIT

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
