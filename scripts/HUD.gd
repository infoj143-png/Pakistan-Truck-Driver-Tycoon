extends CanvasLayer

@onready var money_label = $Control/HBoxContainer/MoneyLabel
@onready var xp_label = $Control/HBoxContainer/XPLabel
@onready var fuel_bar = $Control/FuelContainer/ProgressBar
@onready var time_label = $Control/WeatherContainer/TimeLabel
@onready var weather_label = $Control/WeatherContainer/WeatherLabel

func _ready():
	GameManager.stats_changed.connect(update_ui)
	WeatherManager.time_changed.connect(_on_time_changed)
	WeatherManager.weather_changed.connect(_on_weather_changed)
	update_ui()
	_update_weather_ui()

func update_ui():
	money_label.text = "Rs. " + str(GameManager.money)
	xp_label.text = "XP: " + str(GameManager.xp) + " (Lvl " + str(GameManager.level) + ")"
	_on_time_changed(WeatherManager.get_hour(), WeatherManager.get_minute())

	# Try to find truck in scene to update fuel
	var truck = get_tree().get_first_node_in_group("truck")
	if truck:
		fuel_bar.value = truck.fuel
	else:
		fuel_bar.value = GameManager.fuel

func _on_time_changed(hour, minute):
	time_label.text = "Time: %02d:%02d" % [hour, minute]

func _on_weather_changed(_new_weather):
	_update_weather_ui()

func _update_weather_ui():
	weather_label.text = "Weather: " + WeatherManager.get_weather_name()
