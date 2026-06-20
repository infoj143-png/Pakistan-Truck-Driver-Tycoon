extends CharacterBody2D
class_name Truck

@export var speed = 400.0
@export var acceleration = 150.0
@export var friction = 1.0
@export var steering_limit = 0.6
@export var wheel_base = 70.0

@export var max_fuel = 100.0
var fuel = 100.0

var cargo_loaded: bool:
	get:
		return GameManager.cargo_loaded
	set(value):
		GameManager.cargo_loaded = value

var odometer = 0.0
var is_near_fuel_station = false

var engine_sound: AudioStreamPlayer2D
var horn_sound: AudioStreamPlayer2D

func _ready():
	var stats = GameManager.get_truck_stats(GameManager.selected_truck)
	if stats:
		speed = stats["speed"]
		max_fuel = stats["fuel"]
		# Durability could be used for damage logic, but not yet implemented in base game

	fuel = GameManager.fuel
	if fuel > max_fuel:
		fuel = max_fuel
		GameManager.fuel = fuel

	apply_skin(GameManager.selected_skin)
	GameManager.skin_changed.connect(apply_skin)

	add_to_group("truck")
	setup_audio()

func setup_audio():
	engine_sound = AudioStreamPlayer2D.new()
	engine_sound.bus = "SFX"
	var engine_path = "res://assets/audio/engine_loop.wav"
	if FileAccess.file_exists(engine_path):
		engine_sound.stream = load(engine_path)
		engine_sound.autoplay = true
		# engine_sound.loop = true # Godot 4.x handles looping in import or stream settings
		engine_sound.play()
	add_child(engine_sound)

	horn_sound = AudioStreamPlayer2D.new()
	horn_sound.bus = "Horn"
	var horn_path = "res://assets/audio/truck_horn.wav"
	if FileAccess.file_exists(horn_path):
		horn_sound.stream = load(horn_path)
	add_child(horn_sound)

func apply_skin(skin_id: String):
	if GameManager.SKINS.has(skin_id):
		var color = GameManager.SKINS[skin_id]["color"]
		if has_node("Visuals/Cabin"):
			$Visuals/Cabin.color = color

var steering_angle = 0.0

func _physics_process(delta):
	update_headlights()
	if fuel <= 0:
		velocity = velocity.move_toward(Vector2.ZERO, friction * 100 * delta)
		move_and_slide()
		return

	var forward_input = -Input.get_axis("ui_up", "ui_down")
	var turn_input = Input.get_axis("ui_left", "ui_right")

	# Calculate Steering
	steering_angle = turn_input * steering_limit

	var weather_effects = WeatherManager.WEATHER_EFFECTS[WeatherManager.current_weather]
	var current_accel = acceleration * weather_effects["acceleration_mult"]
	var current_speed = speed * weather_effects["acceleration_mult"]
	var current_friction = friction * weather_effects["friction_mult"]

	if forward_input != 0:
		# Use -transform.y because the truck visuals face UP
		velocity = velocity.move_toward(-transform.y * forward_input * current_speed, current_accel * delta)

		# Consume fuel
		var city_data = GameManager.cities[GameManager.current_city]
		var fuel_mult = city_data["fuel_mult"] * weather_effects["fuel_mult"]
		consume_fuel(delta * 2.0 * fuel_mult)

		# Track distance
		var dist = velocity.length() * delta
		odometer += dist
		if GameManager.owned_trucks.has(GameManager.selected_truck):
			GameManager.owned_trucks[GameManager.selected_truck]["condition"] -= dist * 0.0001
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_friction * 200 * delta)

	# Apply Steering (Bicycle Model)
	# For visuals facing UP (-Y):
	var rear_wheel = position + transform.y * wheel_base / 2.0
	var front_wheel = position - transform.y * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steering_angle) * delta
	var new_dir = (front_wheel - rear_wheel).normalized()

	if velocity.length() > 5.0:
		var travel_dir = velocity.normalized()
		if travel_dir.dot(-transform.y) > 0: # Moving forward
			rotation = new_dir.angle() + PI/2.0
		else: # Moving backward
			rotation = new_dir.angle() - PI/2.0

	move_and_slide()
	update_audio_pitch(delta)

	if Input.is_action_just_pressed("horn") or Input.is_key_pressed(KEY_H):
		play_horn()

func update_audio_pitch(_delta):
	if engine_sound:
		var speed_percent = velocity.length() / speed
		engine_sound.pitch_scale = lerp(1.0, 2.0, speed_percent)

func update_headlights():
	var is_night = WeatherManager.get_hour() >= 19 or WeatherManager.get_hour() <= 5
	if has_node("Visuals/Headlights"):
		for light in $Visuals/Headlights.get_children():
			if light is PointLight2D:
				light.enabled = is_night

func play_horn():
	if horn_sound and horn_sound.stream and not horn_sound.playing:
		horn_sound.play()
	else:
		print("Truck Horn! (SFX missing)")

func set_near_fuel_station(value: bool):
	is_near_fuel_station = value

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
		print("Fuel refilled for Rs. ", int(needed * GameManager.base_fuel_price * GameManager.cities[GameManager.current_city]["fuel_mult"]))
	else:
		print("Not enough money to refill fuel!")
