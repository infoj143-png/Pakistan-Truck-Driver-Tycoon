extends Control

@onready var background_panel = %BackgroundPanel
@onready var buttons_container = $VBoxContainer

func _ready():
	print("[MainMenu] Ready")
	_setup_menu()

func _setup_menu():
	# Apply styling safely
	if is_instance_valid(background_panel):
		background_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["dark_bg"], GameManager.TRUCK_ART_COLORS["red"]))

	if is_instance_valid(buttons_container):
		for child in buttons_container.get_children():
			if child is Button:
				_setup_button(child)

	# Auto-popup Daily Rewards if not claimed today and first time entering menu
	if not GameManager.reward_claimed_today and GameManager.first_time_menu:
		print("[MainMenu] Auto-popping Daily Rewards")
		GameManager.first_time_menu = false
		_on_daily_rewards_pressed()

func _setup_button(btn: Button):
	btn.mouse_entered.connect(_on_button_mouse_entered.bind(btn))
	btn.mouse_exited.connect(_on_button_mouse_exited.bind(btn))
	# Use call_deferred for pivot_offset to ensure size is correct
	btn.call_deferred("set", "pivot_offset", btn.size / 2.0)

	# Apply style to buttons safely using bracket notation
	btn.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["blue"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
	btn.add_theme_stylebox_override("hover", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["orange"], GameManager.TRUCK_ART_COLORS["yellow"], 3))
	btn.add_theme_stylebox_override("pressed", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["red"], GameManager.TRUCK_ART_COLORS["white"], 2))

func _on_button_mouse_entered(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_button_mouse_exited(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_mission_pressed():
	print("[MainMenu] Missions button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Mission.tscn")

func _on_city_selection_pressed():
	print("[MainMenu] Select City button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/CitySelection.tscn")

func _on_garage_pressed():
	print("[MainMenu] Garage button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Garage.tscn")

func _on_profile_pressed():
	print("[MainMenu] Profile button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Profile.tscn")

func _on_daily_rewards_pressed():
	print("[MainMenu] Daily Rewards button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/DailyRewards.tscn")

func _on_achievements_pressed():
	print("[MainMenu] Achievements button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Achievements.tscn")

func _on_company_pressed():
	print("[MainMenu] Company button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/CompanyDashboard.tscn")

func _on_settings_pressed():
	print("[MainMenu] Settings button pressed")
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Settings.tscn")

func _on_quit_pressed():
	print("[MainMenu] Quit button pressed")
	get_tree().quit()
