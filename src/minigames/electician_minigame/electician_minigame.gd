extends Minigame

signal win

@onready var cable_section:Node
@onready var timing_section:Node = $MarginContainer/GamesContainer/PanelContainer2/TimingSection
@onready var moving_section:Node = $MarginContainer/GamesContainer/PanelContainer3/MovingSection
@onready var cable_validated_label:Label = $MarginContainer/CableValidated
@onready var win_label:Label = $WinLabel
@onready var yay_label:Label = $YayLabel
@onready var lose_label:Label = $Loselabel

@export var cables_required:int = 100
var cables_validated:int:
	set(new_val):
		cables_validated = new_val
		cable_validated_label.text = "%d/%d" % [cables_validated, cables_required]

func _ready() -> void:
	cables_validated = 0
	connect_signals()
	win_label.scale = Vector2.ZERO
	lose_label.scale = Vector2.ZERO
	yay_label.scale = Vector2.ZERO
	
	await  get_tree().process_frame
	reset_cable()

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
	timing_section.reset()
	moving_section.reset()
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	
	tween.tween_property(lose_label, "scale", Vector2.ONE, 0.3)
	tween.tween_interval(0.3)
	tween.tween_property(lose_label, "scale", Vector2.ZERO, 0.5)

func reset_cable():
	if cable_section: cable_section.queue_free()
	cable_section = load("res://src/minigames/electician_minigame/cableSection.tscn").instantiate()
	get_node("MarginContainer/GamesContainer/PanelContainer").add_child(cable_section)
	cable_section.completed.connect(on_cable_validated)

func end_game():
	for node:Control in [cable_section, moving_section, timing_section]:
		node.process_mode = Node.PROCESS_MODE_DISABLED
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(win_label, "scale", Vector2.ONE, 0.5)
	tween.tween_interval(2)
	tween.tween_callback(win.emit)
	tween.tween_callback(exit)

func exit():
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.SHOW_GAME3D)
