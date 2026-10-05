extends CharacterBody2D

const speed = 200.0
const jump_velocity = -350
var cut = 2.5
var last_direct = 1
var hp = 0
var item = null
var spawn_point = position
var died = false

func _ready() -> void:
	g.lvl_end = false
	spawn_point = position
	g.player = self
	g.bad.connect(Callable(self, "sad"))

func _physics_process(delta: float) -> void:
	if g.camera:
		g.camera.position = position
	if last_direct < 0:
		%head.flip_h = true
		if item:
			var sprite = item.get_node("AnimatedSprite2D")
			sprite.flip_h = true
	else:
		%head.flip_h = false
		if item:
			var sprite = item.get_node("AnimatedSprite2D")
			sprite.flip_h = false
	if not is_on_floor():
		var grav = get_gravity()
		if velocity.y < 0:
			if not Input.is_action_pressed("w"):
				grav *= cut
		else:
			grav *= 2
		velocity += grav * delta

	if Input.is_action_just_pressed("w") and is_on_floor():
		velocity.y = jump_velocity

	var direction := Input.get_axis("a", "d")
	if direction:
		velocity.x = direction * speed
		last_direct = direction
		if item:
			$AnimatedSprite2D.play("item_walk")
			var sprite = item.get_node("AnimatedSprite2D")
		else:
			$AnimatedSprite2D.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if item:
			$AnimatedSprite2D.play("item_idle")
		else:
			$AnimatedSprite2D.play("idle")

	move_and_slide()

func kill():
	g.dieths += 1
	g.emit_signal("restore")
	position = spawn_point
	velocity = Vector2.ZERO
	%head.play("fun")
	g.camera.get_child(0)._on_texture_button_toggled(false)

func sad():
	%head.play("sad")
