extends TextureButton

@export var importance = false
var save = []
var sounds = [
	preload("res://sounds/chirk_of_pen.mp3"),
	preload("res://sounds/mnogo_pen_chirk.mp3"),
	preload("res://sounds/eraser_chirk.mp3")
	]

func _ready():
	if importance:
		for node in get_children():
			if node.visible:
				save.append([node, node.position])
	if importance:
		g.restore.connect(Callable(self, "_restore"))
	if %sound.stream == sounds[1]:
		return
	%sound.stream = sounds[1]
	%sound.play()

func _restore():
	if save.size() > 0:
		for node in save:
			if node[0] != null:
				if node[0].get_parent() == self:
					node[0].position = node[1]
	disabled = false
	if %sound.stream == sounds[1] or !%sound.is_inside_tree():
		return
	g.restore_counter += 1
	%sound.stream = sounds[1]
	%sound.play()

func _on_paper_pressed() -> void:
	disabled = true
	if get_rect().has_point(g.player.position):
		g.player.call_deferred("kill")
	if importance:
		for node in get_children():
			if node.visible:
				node.position = Vector2(-1000,-1000)
		g.emit_signal("bad")
	else:
		for node in get_children():
			if node.visible:
				node.call_deferred("queue_free")
	g.camera.get_child(0)._on_texture_button_toggled(false)
	g.eraser_counter += 1
	%sound.stream = sounds[2]
	%sound.play()
