extends Camera2D

var default_position: Vector2
var default_zoom: Vector2 = Vector2.ONE
@export var launch_zoom: Vector2 = Vector2(1.5, 1.5)

@onready var entities = $"../Entities"


func setup():
	default_position = get_viewport_rect().size / 2
	global_position = default_position
	default_zoom = Vector2.ONE


func _ready():
	setup()
	connect_entities_signals()


func connect_entities_signals():
	for entity in entities.get_children():
		var hitball = entity.get_node_or_null("HitBall")
		if hitball:
			hitball.caught_ball.connect(zoom_to)
			hitball.released_ball.connect(reset_camera)


func reset_camera(_entity = null):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "global_position", default_position, 0.2)
	tween.parallel().tween_property(self, "zoom", default_zoom, 0.2)


func zoom_to(target):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(self, "global_position", target, 0.2)
	tween.parallel().tween_property(self, "zoom", launch_zoom, 0.2)
