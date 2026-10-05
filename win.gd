extends Area2D

@onready var level: String = get_tree().current_scene.scene_file_path
@onready var next_number = int(level.trim_prefix("res://levels/level")) + 1
@onready var next_level = "res://levels/level" + str(next_number) + ".scn"

func _on_body_entered(body: Node2D) -> void:
	if ResourceLoader.exists(next_level):
		g.lvl_end = true
		get_tree().call_deferred("change_scene_to_file", next_level)
		if next_number > g.lvls_unl:
			g.lvls_unl += 1
