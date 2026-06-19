extends CharacterBody2D

@export var speed = 300.0
@export var acceleration = 5.0
@export var friction = 2.0
@export var rotation_speed = 3.0

@export var max_fuel = 100.0
var fuel = 100.0

var cargo_loaded = false
var odometer = 0.0

func _ready():
	var stats = GameManager.get_truck_stats(GameManager.selected_truck)
	if stats:
		speed = stats.speed
		max_fuel = stats.fuel
		# Durability could be used for damage logic, but not yet implemented in base game

	fuel = GameManager.fuel
	if fuel > max_fuel:
		fuel = max_fuel
		GameManager.fuel = fuel

	apply_skin(GameManager.selected_skin)
	GameManager.skin_changed.connect(apply_skin)

	add_to_group("truck")

func apply_skin(skin_id: String):
	if GameManager.SKINS.has(skin_id):
		$Sprite2D.self_modulate = GameManager.SKINS[skin_id].color

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
		var city_data = GameManager.cities[GameManager.current_city]
		var weather_effects = WeatherManager.WEATHER_EFFECTS[WeatherManager.current_weather]

		var fuel_mult = city_data.fuel_mult * weather_effects.fuel_mult
		var current_speed = speed * weather_effects.acceleration_mult # Limit top speed/acceleration slightly
		var current_accel = acceleration * weather_effects.acceleration_mult
		var current_friction = friction * weather_effects.friction_mult

		var move_step = direction * forward_input * current_speed * delta
		velocity = velocity.lerp(direction * forward_input * current_speed, current_accel * delta)

		# Track distance and decrease condition
		var dist = move_step.length()
		odometer += dist
		if GameManager.owned_trucks.has(GameManager.selected_truck):
			GameManager.owned_trucks[GameManager.selected_truck].condition -= dist * 0.0001
			if GameManager.owned_trucks[GameManager.selected_truck].condition < 0:
				GameManager.owned_trucks[GameManager.selected_truck].condition = 0

		# Consume fuel
		consume_fuel(delta * 2.0 * fuel_mult)
	else:
		var weather_effects = WeatherManager.WEATHER_EFFECTS[WeatherManager.current_weather]
		velocity = velocity.lerp(Vector2.ZERO, friction * weather_effects.friction_mult * delta)

	move_and_slide()

func consume_fuel(amount):
	fuel -= amount
	if fuel < 0:
		fuel = 0
	GameManager.fuel = fuel
	GameManager.stats_changed.emit()

func refill_fuel():
	var needed = max_fuel - fuel
	if needed <= 0: return

	if GameManager.refill_fuel_cost(needed):
		fuel = max_fuel
		GameManager.fuel = fuel
		GameManager.stats_changed.emit()
		print("Fuel refilled for Rs. ", int(needed * GameManager.base_fuel_price * GameManager.cities[GameManager.current_city].fuel_mult))
	else:
		print("Not enough money to refill fuel!")
