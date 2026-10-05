extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not body.item:
		body.item = self
		g.key = self
		call_deferred("reparent", body)
		await get_tree().process_frame
		position = Vector2(-3, -32)
