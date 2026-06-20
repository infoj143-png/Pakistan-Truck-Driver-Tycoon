extends CharacterBody2D
class_name Truck

@export var speed = 300.0
@export var acceleration = 5.0
@export var friction = 2.0
@export var rotation_speed = 3.0

@export var max_fuel = 100.0
var fuel = 100.0

var cargo_loaded: bool:
	get:
		return GameManager.cargo_loaded
	set(value):
		GameManager.cargo_loaded = value

var odometer = 0.0

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
		$Sprite2D.self_modulate = GameManager.SKINS[skin_id]["color"]

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

		var fuel_mult = city_data["fuel_mult"] * weather_effects["fuel_mult"]
		var current_speed = speed * weather_effects["acceleration_mult"] # Limit top speed/acceleration slightly
		var current_accel = acceleration * weather_effects["acceleration_mult"]
		var current_friction = friction * weather_effects["friction_mult"]

		var move_step = direction * forward_input * current_speed * delta
		velocity = velocity.lerp(direction * forward_input * current_speed, current_accel * delta)

		# Track distance and decrease condition
		var dist = move_step.length()
		odometer += dist
		if GameManager.owned_trucks.has(GameManager.selected_truck):
			GameManager.owned_trucks[GameManager.selected_truck]["condition"] -= dist * 0.0001
			if GameManager.owned_trucks[GameManager.selected_truck]["condition"] < 0:
				GameManager.owned_trucks[GameManager.selected_truck]["condition"] = 0

		# Consume fuel
		consume_fuel(delta * 2.0 * fuel_mult)
	else:
		var weather_effects = WeatherManager.WEATHER_EFFECTS[WeatherManager.current_weather]
		velocity = velocity.lerp(Vector2.ZERO, friction * weather_effects["friction_mult"] * delta)

	move_and_slide()
	update_audio_pitch(delta)

	if Input.is_action_just_pressed("horn"): # Need to make sure 'horn' action exists or use a default
		play_horn()
	elif Input.is_key_pressed(KEY_H): # Fallback to H key
		play_horn()

func update_audio_pitch(delta):
	if engine_sound:
		var speed_percent = velocity.length() / speed
		engine_sound.pitch_scale = lerp(1.0, 2.0, speed_percent)

func play_horn():
	if horn_sound and horn_sound.stream and not horn_sound.playing:
		horn_sound.play()
	else:
		print("Truck Horn! (SFX missing)")

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
