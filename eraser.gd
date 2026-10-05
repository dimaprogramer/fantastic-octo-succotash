extends Control

var pre_menu = preload("res://menu.scn")
@onready var eraser: TextureButton = $TextureButton

func _ready() -> void:
	g.camera = get_parent()

func _on_texture_button_toggled(tog: bool) -> void:
	if tog:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		eraser.button_pressed = true
	else:
		mouse_filter = Control.MOUSE_FILTER_STOP
		eraser.button_pressed = false

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("esc"):
		_on_button_pressed()

func _on_button_pressed() -> void:
	%sound.stream = preload("res://sounds/chirk_of_pen.mp3")
	%sound.play()
	if eraser.button_pressed:
		eraser.button_pressed = false
		return
	var menu = get_node_or_null("menu")
	if menu:
		menu.queue_free()
		Engine.time_scale = 1
	else:
		Engine.time_scale = 0
		add_child(pre_menu.instantiate())
