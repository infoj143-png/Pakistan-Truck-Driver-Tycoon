extends Control

@onready var city_buttons = $MapContainer/Cities
@onready var info_label = $InfoPanel/VBoxContainer/CityInfo
@onready var travel_button = $InfoPanel/VBoxContainer/TravelButton

var selected_city: String = ""

func _ready():
	selected_city = GameManager.current_city
	update_city_buttons()
	update_info_panel()

func update_city_buttons():
	for button in city_buttons.get_children():
		var city_name = button.name
		var is_unlocked = city_name in GameManager.unlocked_cities

		if is_unlocked:
			button.disabled = false
			if city_name == GameManager.current_city:
				button.modulate = Color.GREEN
			else:
				button.modulate = Color.WHITE
		else:
			button.disabled = true
			button.modulate = Color.GRAY

		if not button.pressed.is_connected(_on_city_pressed.bind(city_name)):
			button.pressed.connect(_on_city_pressed.bind(city_name))

func _on_city_pressed(city_name: String):
	selected_city = city_name
	update_info_panel()
	# Highlight selected city
	for button in city_buttons.get_children():
		if button.name == selected_city:
			button.modulate = Color.YELLOW
		elif button.name == GameManager.current_city:
			button.modulate = Color.GREEN
		elif button.name in GameManager.unlocked_cities:
			button.modulate = Color.WHITE
		else:
			button.modulate = Color.GRAY

func update_info_panel():
	var data = GameManager.cities[selected_city]
	var status = "UNLOCKED" if selected_city in GameManager.unlocked_cities else "LOCKED (Level " + str(data.unlock_level) + ")"

	info_label.text = "City: " + selected_city + "\n" + \
					 "Status: " + status + "\n" + \
					 "Reward Multiplier: x" + str(data.reward_mult) + "\n" + \
					 "Fuel Consumption: x" + str(data.fuel_mult) + "\n" + \
					 "Difficulty: " + str(data.difficulty)

	travel_button.disabled = selected_city == GameManager.current_city or not (selected_city in GameManager.unlocked_cities)
	if selected_city == GameManager.current_city:
		travel_button.text = "Already Here"
	else:
		travel_button.text = "Travel to " + selected_city

func _on_travel_pressed():
	if selected_city in GameManager.unlocked_cities:
		GameManager.current_city = selected_city
		GameManager.save_game()
		update_city_buttons()
		update_info_panel()
		print("Traveled to ", selected_city)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
