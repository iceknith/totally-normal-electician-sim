class_name countdown_label extends Label



func animate_countdown(number:int = 3, duration:float = 3) -> void:
	var in_time = duration * 0.4
	var out_time = duration * 0.3
	
	text = str(number)
	scale = Vector2(2.5, 2.5)
	modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), in_time)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self, "modulate:a", 1.0, in_time * 0.5)\
		.set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	var tween_out = create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_property(self, "scale", Vector2(0.5, 0.5), out_time)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween_out.tween_property(self, "modulate:a", 0.0, out_time)\
		.set_ease(Tween.EASE_IN)
	
	await tween_out.finished

func start_countdown(from:int = 3, total_duration:float = 3) -> void:
	var step_duration = total_duration / (from + 1)
	var anim_duration = step_duration * 0.8
	var wait_duration = step_duration * 0.2
	
	for i in range(from, 0, -1):
		await animate_countdown(i, anim_duration)
		await get_tree().create_timer(wait_duration).timeout
	
	text = "GO!"
	scale = Vector2(3.0, 3.0)
	modulate.a = 0
	
	var tween_go = create_tween()
	tween_go.set_parallel(true)
	tween_go.tween_property(self, "scale", Vector2(1.2, 1.2), step_duration * 0.5)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_go.tween_property(self, "modulate:a", 1.0, step_duration * 0.2)
	
	await tween_go.finished
	await get_tree().create_timer(step_duration * 0.3).timeout
	
	var tween_go_out = create_tween()
	tween_go_out.tween_property(self, "modulate:a", 0.0, step_duration * 0.4)\
		.set_ease(Tween.EASE_IN)
	
	await tween_go_out.finished
	visible = false
