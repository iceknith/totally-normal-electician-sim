@tool extends Node3D

@export var maxHeight:float 
@export_tool_button("CleanUp", "Callable") var cleanup = clean_scene

func clean_scene():
	for child in get_children():
		if child.global_position.y > maxHeight:
			child.queue_free()
