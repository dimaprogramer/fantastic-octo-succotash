extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if !g.lvl_end:
		body.hp += 1

func _on_body_exited(body: Node2D) -> void:
	if !g.lvl_end:
		body.hp -= 1
		if body.hp < 1:
			body.kill()
