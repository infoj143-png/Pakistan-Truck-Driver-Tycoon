extends Control

@onready var background_panel = %BackgroundPanel
@onready var buttons_container = $VBoxContainer

func _ready():
	# Apply styling
	background_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["dark_bg"], GameManager.TRUCK_ART_COLORS["red"]))

	for child in buttons_container.get_children():
		if child is Button:
			child.mouse_entered.connect(_on_button_mouse_entered.bind(child))
			child.mouse_exited.connect(_on_button_mouse_exited.bind(child))
			child.pivot_offset = child.size / 2.0
			# Apply style to buttons too
			child.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["blue"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
			child.add_theme_stylebox_override("hover", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["orange"], GameManager.TRUCK_ART_COLORS["yellow"], 3))
			child.add_theme_stylebox_override("pressed", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["red"], GameManager.TRUCK_ART_COLORS["white"], 2))

	# Auto-popup Daily Rewards if not claimed today
	if not GameManager.reward_claimed_today:
		_on_daily_rewards_pressed()

func _on_button_mouse_entered(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.1, 1.1), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_button_mouse_exited(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_mission_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Mission.tscn")

func _on_city_selection_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/CitySelection.tscn")

func _on_garage_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Garage.tscn")

func _on_profile_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Profile.tscn")

func _on_daily_rewards_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/DailyRewards.tscn")

func _on_achievements_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Achievements.tscn")

func _on_company_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/CompanyDashboard.tscn")

func _on_settings_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/Settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
