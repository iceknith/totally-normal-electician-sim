class_name Interractable extends Area3D

@export var function_on_interract:Callable
@export var action:String = "interract"

@onready var text_sprite:Sprite3D = $Sprite3D
@onready var text_label:Label = $SubViewport/PanelContainer/MarginContainer/Label

func _ready() -> void:
	change_text()

func _process(delta: float) -> void:
	pass

func change_text() -> void:
	pass

func player_viewing() -> void:
	pass

func player_stop_view() -> void:
	pass
