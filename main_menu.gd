extends Node2D

var sounds: Array = [
	preload("res://sounds/chirk_of_pen.mp3"),
	preload("res://sounds/mnogo_pen_chirk.mp3"),
	preload("res://sounds/eraser_chirk.mp3")
	]
@onready var buttons: Array = %note_book.get_children()
@onready var autor: Control = $autor
@onready var guide: Control = $guide
@onready var settings: TextureRect = %note_book2
@onready var levels_list: GridContainer = $Control/levels_list
@onready var lvls_btns: Array = $Control/levels_list.get_children()
@onready var control: Control = $Control

func _ready() -> void:
	for btn in buttons:
		btn.mouse_entered.connect(mouse_entered.bind(btn))
		btn.mouse_exited.connect(mouse_exited.bind(btn))
	var c = 0
	for btn in lvls_btns:
		c += 1
		btn.pressed.connect(_on_level_pressed.bind(btn))
		var label: Label = btn.get_child(0)
		if c <= g.lvls_unl:
			btn.get_child(1).queue_free()
			btn.disabled = false
		label.text = "Ур
		" + btn.name.trim_prefix("level") 
	AudioServer.set_bus_volume_linear(1, g.music[1])
	AudioServer.set_bus_volume_linear(2, g.sounds[1])
	%music_slider.value = g.music[1] * 100
	%sounds_slider.value = g.sounds[1] * 100
	%music_mute.button_pressed = g.music[0]
	%sounds_mute.button_pressed = g.sounds[0]
	if !mp.playing or mp.stream != preload("res://sounds/main_menu.mp3"):
		mp.volume_db = -10
		mp.stream = preload("res://sounds/main_menu.mp3")
		mp.play()
	if DisplayServer.window_get_mode(3):
		%full_screen.button_pressed = true

func mouse_entered(btn) -> void:
	btn.material.set_shader_parameter("color_strength", 1)

func mouse_exited(btn) -> void:
	btn.material.set_shader_parameter("color_strength", 0)

func _on_play_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	control.visible = true
	%note_book.visible = false
	%title.visible = false

func _on_settings_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	settings.visible = true
	%title.visible = false

func _on_autor_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	autor.visible = true
	%title.visible = false

func _on_guide_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	guide.visible = true
	%title.visible = false

func _on_exit_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	OS.shell_open("https://youtu.be/dQw4w9WgXcQ?si=jH21q5F19Q00GUBT")
	AudioServer.set_bus_mute(1, true)
	AudioServer.set_bus_mute(2, true)

func _on_button_pressed() -> void:
	guide.visible = false
	autor.visible = false
	settings.visible = false
	control.visible = false
	%note_book.visible = true
	%title.visible = true
	%sound.stream = sounds[0]
	%sound.play()

func _on_music_mute_pressed() -> void:
	AudioServer.set_bus_mute(1, !%music_mute.button_pressed)
	%sound.stream = sounds[0]
	%sound.play()

func _on_sounds_mute_pressed() -> void:
	AudioServer.set_bus_mute(2, !%sounds_mute.button_pressed)
	%sound.stream = sounds[0]
	%sound.play()

func _on_sounds_slider_value_changed(value: float) -> void:
	g.sounds[1] = value / 100
	AudioServer.set_bus_volume_linear(2, value / 100)
	%sound.stream = sounds[0]
	%sound.play()

func _on_music_slider_value_changed(value: float) -> void:
	g.music[1] = value / 100
	AudioServer.set_bus_volume_linear(1, value / 100)
	%sound.stream = sounds[0]
	%sound.play()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		settings.visible = false
		guide.visible = false
		autor.visible = false
		control.visible = false
		%note_book.visible = true
		%title.visible = true

func _on_level_pressed(btn) -> void:
	mp.volume_db = 0
	mp.stream = preload("res://sounds/Nocturne_in_E_flat_major,_Op._9_no._2.mp3")
	var lvl = "res://levels/" + btn.name + ".scn"
	get_tree().change_scene_to_file(lvl)
	mp.play()

func _on_link_pressed() -> void:
	OS.shell_open("https://itch.io/profile/dimaprogramer")

func _on_link_2_pressed() -> void:
	OS.shell_open("https://www.youtube.com/@dima_yt")

func _on_link_3_pressed() -> void:
	OS.shell_open("https://commons.wikimedia.org/wiki/File:Nocturne_in_E_flat_major,_Op._9_no._2.mp3")

func _on_full_screen_pressed() -> void:
	if %full_screen.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
