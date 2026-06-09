class_name Newspaper extends Interactable3D

@onready var sprite:Sprite3D = $Sprite3D

static var newspaper_show_scene:PackedScene = preload("res://src/minigames/newspaper_show.tscn")
static var newspaper_directory:String = "res://assets/newspaper/"
static var newspaper_textures:Array[Texture] = []

static func init_textures():
	newspaper_textures.clear()
	for texture in ResourceLoader.list_directory(newspaper_directory):
		newspaper_textures.append(load(newspaper_directory + texture))


func _ready() -> void:
	if newspaper_textures.is_empty(): init_textures()
	else:
		sprite.texture = newspaper_textures.pop_at(
			randi_range(0, newspaper_textures.size()-1)
			)
	super()

func start_interaction():
	MainCommunicator.send_signal_to_main(
		MainCommunicator.SignalType.ADD_MINIGAME, 
		[
			newspaper_show_scene,
			{"texture": sprite.texture}
		]
		)
	MainCommunicator.send_signal_to_main(MainCommunicator.SignalType.ELEM_DELETED, self)
	queue_free.call_deferred()
