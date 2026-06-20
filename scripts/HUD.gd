extends CanvasLayer

@onready var money_label = %MoneyLabel
@onready var xp_label = %XPLabel
@onready var fuel_bar = %FuelBar
@onready var time_label = %TimeLabel
@onready var weather_label = %WeatherLabel

@onready var money_panel = %MoneyPanel
@onready var xp_panel = %XPPanel
@onready var fuel_panel = %FuelPanel
@onready var weather_panel = %WeatherPanel
@onready var minimap = %MiniMap
@onready var toggle_map_btn = %ToggleMapButton
@onready var refuel_btn = %RefuelButton
@onready var emergency_fuel_btn = %EmergencyFuelButton

func _ready():
	# Apply styling
	if money_panel:
		money_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["blue"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
	if xp_panel:
		xp_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["green"], GameManager.TRUCK_ART_COLORS["white"], 2))
	if fuel_panel:
		fuel_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["red"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
	if weather_panel:
		weather_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["pink"], GameManager.TRUCK_ART_COLORS["white"], 2))

	GameManager.stats_changed.connect(update_ui)
	WeatherManager.time_changed.connect(_on_time_changed)
	WeatherManager.weather_changed.connect(_on_weather_changed)

	if minimap:
		minimap.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["dark_bg"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
	if toggle_map_btn:
		toggle_map_btn.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["orange"], GameManager.TRUCK_ART_COLORS["white"], 2))

	if refuel_btn:
		refuel_btn.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["green"], GameManager.TRUCK_ART_COLORS["white"], 3))
		refuel_btn.pressed.connect(_on_refuel_pressed)

	if emergency_fuel_btn:
		emergency_fuel_btn.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["red"], GameManager.TRUCK_ART_COLORS["yellow"], 3))
		emergency_fuel_btn.pressed.connect(_on_emergency_fuel_pressed)

	setup_touch_visuals()
	update_ui()
	_update_weather_ui()

func _process(_delta):
	# Update fuel in real-time if a truck exists
	var truck = get_tree().get_first_node_in_group("truck")
	if fuel_bar:
		if truck:
			fuel_bar.value = truck.fuel
			if refuel_btn:
				refuel_btn.visible = truck.is_near_fuel_station and truck.fuel < truck.max_fuel
			if emergency_fuel_btn:
				emergency_fuel_btn.visible = truck.fuel <= 0
		else:
			fuel_bar.value = GameManager.fuel

func _on_refuel_pressed():
	AudioManager.play_ui_click()
	var truck = get_tree().get_first_node_in_group("truck")
	if truck:
		truck.refill_fuel()

func _on_emergency_fuel_pressed():
	AudioManager.play_ui_click()
	GameManager.emergency_refuel()
	var truck = get_tree().get_first_node_in_group("truck")
	if truck:
		truck.fuel = GameManager.fuel

func update_ui():
	if money_label:
		money_label.text = "Rs. " + str(GameManager.money)
	if xp_label:
		xp_label.text = "XP: " + str(GameManager.xp) + " (Lvl " + str(GameManager.level) + ")"

	_on_time_changed(WeatherManager.get_hour(), WeatherManager.get_minute())

func _on_time_changed(hour, minute):
	if time_label:
		time_label.text = "Time: %02d:%02d" % [hour, minute]

func _on_weather_changed(_new_weather):
	_update_weather_ui()

func _update_weather_ui():
	if weather_label:
		weather_label.text = "Weather: " + WeatherManager.get_weather_name()

func setup_touch_visuals():
	var left_btn = $Control/TouchControls/Steering/Left
	var right_btn = $Control/TouchControls/Steering/Right
	var up_btn = $Control/TouchControls/Pedals/Up
	var down_btn = $Control/TouchControls/Pedals/Down

	# Create simple textures for touch buttons since icon.svg might be missing or ugly
	var tex = PlaceholderTexture2D.new()
	tex.size = Vector2(80, 80)

	left_btn.texture_normal = tex
	right_btn.texture_normal = tex
	up_btn.texture_normal = tex
	down_btn.texture_normal = tex

	# Add labels for clarity
	_add_label_to_button(left_btn, "L")
	_add_label_to_button(right_btn, "R")
	_add_label_to_button(up_btn, "GO")
	_add_label_to_button(down_btn, "STOP")

func _add_label_to_button(btn, text):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Center the label on the button
	label.size = Vector2(80, 80)
	btn.add_child(label)

func _on_toggle_map_button_pressed():
	AudioManager.play_ui_click()
	if minimap and toggle_map_btn:
		minimap.visible = !minimap.visible
		if minimap.visible:
			toggle_map_btn.text = "Hide Map"
		else:
			toggle_map_btn.text = "Show Map"
