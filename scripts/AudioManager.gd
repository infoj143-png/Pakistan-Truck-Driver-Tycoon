extends Node

signal volume_changed(bus_name, value)

var music_volume: float = 0.8
var sfx_volume: float = 0.8
var horn_volume: float = 0.8

var audio_players: Dictionary = {}

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	setup_audio_buses()
	load_audio_settings()

	# Connect to GameManager signals for global sounds
	if GameManager:
		GameManager.mission_completed.connect(_on_mission_completed)
		GameManager.stats_changed.connect(_on_stats_changed)

	# Connect to WeatherManager for environmental sounds
	if WeatherManager:
		WeatherManager.weather_changed.connect(_on_weather_changed)

func setup_audio_buses():
	# In a real Godot project, these buses would be defined in a .bus layout file.
	# Here we assume standard Master bus and we'll manage volumes via code or bus names if they exist.
	# For simplicity in this implementation, we'll use bus names "Music", "SFX", "Horn".
	# If they don't exist, they'll default to Master.
	pass

func set_bus_volume(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		bus_index = AudioServer.get_bus_index("Master")

	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

	match bus_name:
		"Music": music_volume = value
		"SFX": sfx_volume = value
		"Horn": horn_volume = value

	volume_changed.emit(bus_name, value)
	save_audio_settings()

func play_sound(sound_name: String, bus: String = "SFX"):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = bus

	# Placeholder for actual stream loading
	# var stream = load("res://assets/audio/" + sound_name + ".wav")
	# player.stream = stream

	# player.play()
	# player.finished.connect(player.queue_free)

	# Since we don't have real files, we just print for now
	print("Playing sound: ", sound_name, " on bus: ", bus)
	player.queue_free()

func play_ui_click():
	play_sound("ui_click")

func _on_mission_completed(_money, _xp):
	play_sound("mission_complete")

var _last_money = -1
func _on_stats_changed():
	if GameManager.money > _last_money and _last_money != -1:
		play_sound("money_reward")
	_last_money = GameManager.money

func _on_weather_changed(new_weather):
	if new_weather == WeatherManager.Weather.RAIN:
		start_rain_sound()
	else:
		stop_rain_sound()

func start_rain_sound():
	print("Starting rain sound loop")

func stop_rain_sound():
	print("Stopping rain sound loop")

func start_city_ambience():
	print("Starting city ambience loop")

func stop_city_ambience():
	print("Stopping city ambience loop")

func save_audio_settings():
	var file = FileAccess.open("user://audio_settings.dat", FileAccess.WRITE)
	if file:
		var data = {
			"music_volume": music_volume,
			"sfx_volume": sfx_volume,
			"horn_volume": horn_volume
		}
		file.store_var(data)
		file.close()

func load_audio_settings():
	if FileAccess.file_exists("user://audio_settings.dat"):
		var file = FileAccess.open("user://audio_settings.dat", FileAccess.READ)
		if file:
			var data = file.get_var()
			if data:
				music_volume = data.get("music_volume", 0.8)
				sfx_volume = data.get("sfx_volume", 0.8)
				horn_volume = data.get("horn_volume", 0.8)

				set_bus_volume("Music", music_volume)
				set_bus_volume("SFX", sfx_volume)
				set_bus_volume("Horn", horn_volume)
			file.close()
