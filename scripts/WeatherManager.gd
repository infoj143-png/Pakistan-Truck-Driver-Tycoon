extends Node

signal weather_changed(new_weather)
signal time_changed(hour, minute)

enum Weather { CLEAR, RAIN, FOG }
enum TimeOfDay { SUNRISE, DAY, SUNSET, NIGHT }

var current_weather: Weather = Weather.CLEAR
var current_time: float = 8.0 # Start at 8 AM
var time_scale: float = 0.2 # 24 hours in 120 seconds -> 24 / 120 = 0.2 hours per second

const WEATHER_EFFECTS = {
	Weather.CLEAR: {"fuel_mult": 1.0, "friction_mult": 1.0, "acceleration_mult": 1.0},
	Weather.RAIN: {"fuel_mult": 1.2, "friction_mult": 0.7, "acceleration_mult": 0.8},
	Weather.FOG: {"fuel_mult": 1.1, "friction_mult": 0.9, "acceleration_mult": 0.9}
}

const TIME_COLORS = {
	TimeOfDay.SUNRISE: Color(1.0, 0.7, 0.5),
	TimeOfDay.DAY: Color(1.0, 1.0, 1.0),
	TimeOfDay.SUNSET: Color(0.8, 0.5, 0.5),
	TimeOfDay.NIGHT: Color(0.1, 0.1, 0.3)
}

func _ready():
	# Initialize from GameManager if it has loaded weather state
	if GameManager and GameManager._loaded_weather_state:
		current_weather = GameManager._loaded_weather_state["weather"]
		current_time = GameManager._loaded_weather_state["time"]
		weather_changed.emit(current_weather)

func _process(delta):
	current_time += delta * time_scale
	if current_time >= 24.0:
		current_time -= 24.0

	time_changed.emit(get_hour(), get_minute())

	# Random weather change every 6 game hours (roughly)
	if randf() < 0.001: # Small chance every frame
		_randomize_weather()

func _randomize_weather():
	var r = randf()
	var new_weather = Weather.CLEAR
	if r < 0.7:
		new_weather = Weather.CLEAR
	elif r < 0.9:
		new_weather = Weather.RAIN
	else:
		new_weather = Weather.FOG

	if new_weather != current_weather:
		current_weather = new_weather
		weather_changed.emit(current_weather)

func get_hour() -> int:
	return int(current_time)

func get_minute() -> int:
	return int((current_time - int(current_time)) * 60)

func get_time_of_day() -> TimeOfDay:
	if current_time >= 5.0 and current_time < 8.0:
		return TimeOfDay.SUNRISE
	elif current_time >= 8.0 and current_time < 17.0:
		return TimeOfDay.DAY
	elif current_time >= 17.0 and current_time < 20.0:
		return TimeOfDay.SUNSET
	else:
		return TimeOfDay.NIGHT

func get_ambient_color() -> Color:
	var tod = get_time_of_day()
	var color = TIME_COLORS[tod]

	# Apply weather dimming
	if current_weather == Weather.RAIN:
		color = color.darkened(0.2)
	elif current_weather == Weather.FOG:
		color = color.lerp(Color.GRAY, 0.3)

	return color

func get_weather_name() -> String:
	match current_weather:
		Weather.CLEAR: return "Clear"
		Weather.RAIN: return "Rainy"
		Weather.FOG: return "Foggy"
	return "Unknown"
