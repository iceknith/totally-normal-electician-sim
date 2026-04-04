extends Control

@export var tower_completed_text_layout = "%d/%d"

func _ready() -> void:
	connect_signals()
	on_tower_completed_value_change()

func connect_signals() -> void:
	GlobalVars.tower_completed_value_change.connect(on_tower_completed_value_change)

func on_tower_completed_value_change():
	$MarginContainer/TowersCompleted.text = tower_completed_text_layout % [GlobalVars.tower_completed, GlobalVars.tower_amount]
