extends CharacterBody2D

var speed: float = 0.0
var max_speed: float = 400.0
var acceleration: float = 200.0
var friction: float = 100.0
var steer_speed: float = 3.0
var fuel_consumption_rate: float = 2.0

var touch_input: Vector2 = Vector2.ZERO

func _unhandled_input(event):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var screen_size = get_viewport_rect().size
		var touch_pos = event.position

		# Simple touch controls:
		# Top half of screen = Accelerate
		# Bottom half = Brake/Reverse
		# Left half = Steer Left
		# Right half = Steer Right

		if touch_pos.y < screen_size.y * 0.5:
			touch_input.y = -1 # Forward
		else:
			touch_input.y = 1 # Backward

		if touch_pos.x < screen_size.x * 0.5:
			touch_input.x = -1 # Left
		else:
			touch_input.x = 1 # Right

		if event is InputEventScreenTouch and not event.pressed:
			touch_input = Vector2.ZERO

func _physics_process(delta):
	if GameManager.fuel <= 0:
		speed = move_toward(speed, 0, friction * delta)
	else:
		_handle_movement(delta)
		_consume_fuel(delta)

	velocity = Vector2.UP.rotated(rotation) * speed
	move_and_slide()

func _handle_movement(delta):
	var input_dir = touch_input

	# Keyboard fallback
	if input_dir == Vector2.ZERO:
		input_dir.y = Input.get_axis("ui_up", "ui_down")
		input_dir.x = Input.get_axis("ui_left", "ui_right")

	if input_dir.y != 0:
		speed += -input_dir.y * acceleration * delta
	else:
		speed = move_toward(speed, 0, friction * delta)

	speed = clamp(speed, -max_speed/2, max_speed)

	if speed != 0:
		# Steering sensitivity depends on speed
		var steer_factor = clamp(abs(speed) / max_speed, 0.1, 1.0)
		rotation += input_dir.x * steer_speed * delta * steer_factor * sign(speed)

func _consume_fuel(delta):
	if abs(speed) > 10:
		var consumption = fuel_consumption_rate * delta * (abs(speed) / max_speed)
		GameManager.fuel -= consumption
		if GameManager.fuel < 0:
			GameManager.fuel = 0
