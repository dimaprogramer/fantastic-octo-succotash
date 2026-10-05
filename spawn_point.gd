extends Node2D

func _ready() -> void:
	var player = preload("res://objects/player.scn").instantiate()
	player.position = self.position
	await get_tree().physics_frame
	get_tree().current_scene.call_deferred("add_child", player)
