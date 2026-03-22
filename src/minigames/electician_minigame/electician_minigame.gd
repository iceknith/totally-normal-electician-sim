extends Minigame

@onready var cable_section = $MarginContainer/VFlowContainer/PanelContainer/CableSection

func _ready() -> void:
	connect_signals()

func connect_signals() -> void:
	cable_section.completed.connect(new_cable_section)

func new_cable_section():
	cable_section.queue_free()
	cable_section = load("res://src/minigames/electician_minigame/cableSection.tscn").instantiate()
	get_node("MarginContainer/VFlowContainer/PanelContainer").add_child(cable_section)
	cable_section.completed.connect(new_cable_section)
