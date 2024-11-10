extends Area2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= get_parent().speed / 2.5

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet-dyno"):
		area.queue_free()
		queue_free()
		get_parent().bird_score += 1
