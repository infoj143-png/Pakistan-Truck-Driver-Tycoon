extends Control

func _ready():
	# Auto-popup Daily Rewards if not claimed today
	if not GameManager.reward_claimed_today:
		_on_daily_rewards_pressed()

func _on_mission_pressed():
	get_tree().change_scene_to_file("res://ui/Mission.tscn")

func _on_city_selection_pressed():
	get_tree().change_scene_to_file("res://ui/CitySelection.tscn")

func _on_garage_pressed():
	get_tree().change_scene_to_file("res://ui/Garage.tscn")

func _on_profile_pressed():
	get_tree().change_scene_to_file("res://ui/Profile.tscn")

func _on_daily_rewards_pressed():
	get_tree().change_scene_to_file("res://ui/DailyRewards.tscn")

func _on_achievements_pressed():
	get_tree().change_scene_to_file("res://ui/Achievements.tscn")

func _on_company_pressed():
	get_tree().change_scene_to_file("res://ui/CompanyDashboard.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://ui/Settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
