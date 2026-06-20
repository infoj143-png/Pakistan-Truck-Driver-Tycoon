extends CanvasLayer

@onready var money_label = %MoneyLabel
@onready var xp_label = %XPLabel
@onready var fuel_bar = %ProgressBar
@onready var time_label = $Control/WeatherPanel/WeatherContainer/MarginContainer/VBox/TimeLabel
@onready var weather_label = $Control/WeatherPanel/WeatherContainer/MarginContainer/VBox/WeatherLabel

@onready var money_panel = %MoneyPanel
@onready var xp_panel = %XPPanel
@onready var fuel_panel = %FuelPanel
@onready var weather_panel = %WeatherPanel

func _ready():
	# Apply styling
	money_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS.blue, GameManager.TRUCK_ART_COLORS.yellow, 2))
	xp_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS.green, GameManager.TRUCK_ART_COLORS.white, 2))
	fuel_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS.red, GameManager.TRUCK_ART_COLORS.yellow, 2))
	weather_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS.pink, GameManager.TRUCK_ART_COLORS.white, 2))

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
