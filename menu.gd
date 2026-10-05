extends Control

var sounds = [
	preload("res://sounds/chirk_of_pen.mp3"),
	preload("res://sounds/mnogo_pen_chirk.mp3"),
	preload("res://sounds/eraser_chirk.mp3")
	]
@onready var buttons = %note_book.get_children()
@onready var guide: Control = $guide
@onready var settings: TextureRect = %note_book2

func _ready() -> void:
	for btn in buttons:
		btn.mouse_entered.connect(mouse_entered.bind(btn.get_child(0)))
		btn.mouse_exited.connect(mouse_exited.bind(btn.get_child(0)))
	%music_slider.value = g.music[1] * 100
	%sounds_slider.value = g.sounds[1] * 100
	%music_mute.button_pressed = g.music[0]
	%sounds_mute.button_pressed = g.sounds[0]
	AudioServer.set_bus_mute(1, !%music_mute.button_pressed)
	AudioServer.set_bus_mute(2, !%sounds_mute.button_pressed)
	_on_music_slider_value_changed(%music_slider.value)
	_on_sounds_slider_value_changed(%sounds_slider.value)
	var lvl_name = get_tree().current_scene.name.trim_prefix("level")
	%level_name.text = "Уровень " + lvl_name
	if DisplayServer.window_get_mode(3):
		%full_screen.button_pressed = true

func mouse_entered(btn) -> void:
	btn.material.set_shader_parameter("red", 1)
	btn.material.set_shader_parameter("green", 1)
	btn.material.set_shader_parameter("blue", 1)

func mouse_exited(btn) -> void:
	btn.material.set_shader_parameter("red", 0.1921)
	btn.material.set_shader_parameter("green", 0.1921)
	btn.material.set_shader_parameter("blue", 0.1921)

func _on_play_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	Engine.time_scale = 1
	queue_free()

func _on_settings_pressed() -> void:
	g.lvl_end = true
	get_tree().reload_current_scene()
	Engine.time_scale = 1

func _on_autor_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	settings.visible = true

func _on_guide_pressed() -> void:
	%sound.stream = sounds[0]
	%sound.play()
	guide.visible = true

func _on_exit_pressed() -> void:
	g.lvl_end = true
	Engine.time_scale = 1
	%sound.stream = sounds[0]
	%sound.play()
	get_tree().change_scene_to_file("res://main_menu.scn")

func _on_button_pressed() -> void:
	guide.visible = false
	settings.visible = false
	%sound.stream = sounds[0]
	%sound.play()

func _on_music_mute_pressed() -> void:
	AudioServer.set_bus_mute(1, !%music_mute.button_pressed)
	%sound.stream = sounds[0]
	%sound.play()
	mp.play()

func _on_sounds_mute_pressed() -> void:
	AudioServer.set_bus_mute(2, !%sounds_mute.button_pressed)
	%sound.stream = sounds[0]
	%sound.play()

func _on_sounds_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(2, value / 100)
	g.sounds[1] = value / 100
	%sound.stream = sounds[0]
	%sound.play()
	release_focus()

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(1, value / 100)
	g.music[1] = value / 100
	%sound.stream = sounds[0]
	%sound.play()
	release_focus()

func _on_full_screen_pressed() -> void:
	if %full_screen.button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
