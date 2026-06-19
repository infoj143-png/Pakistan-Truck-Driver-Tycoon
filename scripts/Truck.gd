extends CharacterBody2D

@export var speed = 300.0
@export var acceleration = 5.0
@export var friction = 2.0
@export var rotation_speed = 3.0

@export var max_fuel = 100.0
var fuel = 100.0

var cargo_loaded = false

func _ready():
	fuel = GameManager.fuel
	add_to_group("truck")

func _physics_process(delta):
	if fuel <= 0:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)
		move_and_slide()
		return

	# ui_up is -1, ui_down is 1. We want 1 to be forward (up)
	var forward_input = -Input.get_axis("ui_up", "ui_down")
	var turn_input = Input.get_axis("ui_left", "ui_right")

	# Rotate based on turn input and movement direction
	if forward_input != 0:
		rotation += turn_input * rotation_speed * delta * (1.0 if forward_input > 0 else -1.0)

	var direction = Vector2.UP.rotated(rotation)
	if forward_input != 0:
		velocity = velocity.lerp(direction * forward_input * speed, acceleration * delta)
		# Consume fuel
		consume_fuel(delta * 2.0)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction * delta)

	move_and_slide()

func consume_fuel(amount):
	fuel -= amount
	if fuel < 0:
		fuel = 0
	GameManager.fuel = fuel
	GameManager.stats_changed.emit()

func refill_fuel():
	fuel = max_fuel
	GameManager.fuel = fuel
	GameManager.stats_changed.emit()
