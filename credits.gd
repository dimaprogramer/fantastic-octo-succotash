extends Node2D

var page = 1
@onready var label: Label = $autor2/list/Label

func _ready() -> void:
	mp.volume_db = -10
	mp.stream = preload("res://sounds/main_menu.mp3")
	mp.play()

func _on_link_pressed() -> void:
	OS.shell_open("https://itch.io/profile/dimaprogramer")

func _on_link_2_pressed() -> void:
	OS.shell_open("https://www.youtube.com/@dima_yt")

func _on_link_3_pressed() -> void:
	OS.shell_open("https://commons.wikimedia.org/wiki/File:Nocturne_in_E_flat_major,_Op._9_no._2.mp3")

func _on_button_pressed() -> void:
	if page == 1:
		label.text = "Смертей: " + str(g.dieths) + "
		" + "Смертей (без учёта необходимых): " + str(g.dieths - 3) + "
		" + "Очищенных листов: " + str(g.eraser_counter) + "
		" + "Очищеных листов (без учёта восстановленых): " + str(g.eraser_counter - g.restore_counter)
		$autor.visible = false
		page = 2
	else:
		get_tree().change_scene_to_file("res://main_menu.scn")
