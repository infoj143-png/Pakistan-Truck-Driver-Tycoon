extends Node2D

@onready var day_night_cycle = $DayNightCycle
@onready var rain_particles = $WeatherEffects/Rain
@onready var fog_overlay = $WeatherEffects/Fog

func _ready():
	WeatherManager.weather_changed.connect(_on_weather_changed)
	WeatherManager.time_changed.connect(_on_time_changed)

	# Initial update
	_update_visuals()

	if AudioManager:
		AudioManager.start_city_ambience()
		if WeatherManager.current_weather == WeatherManager.Weather.RAIN:
			AudioManager.start_rain_sound()

func _exit_tree():
	if AudioManager:
		AudioManager.stop_city_ambience()
		AudioManager.stop_rain_sound()

func _process(_delta):
	# Smoothly update lighting every frame
	day_night_cycle.color = WeatherManager.get_ambient_color()

func _on_weather_changed(_new_weather):
	_update_visuals()

func _on_time_changed(_hour, _minute):
	# Lighting is handled in _process for smoothness
	pass

func _update_visuals():
	var weather = WeatherManager.current_weather

	# Rain particles
	rain_particles.emitting = (weather == WeatherManager.Weather.RAIN)

	# Fog overlay
	if weather == WeatherManager.Weather.FOG:
		fog_overlay.color.a = 0.3
	else:
		fog_overlay.color.a = 0.0
