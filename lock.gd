extends Area2D

func _on_area_entered(area: Area2D) -> void:
	area.call_deferred("queue_free")
	get_parent().call_deferred("queue_free")
	%sound.stream = preload("res://sounds/lock.mp3")
	%sound.play()
