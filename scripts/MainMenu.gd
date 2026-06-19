extends Control

func _on_mission_pressed():
	get_tree().change_scene_to_file("res://ui/Mission.tscn")

func _on_garage_pressed():
	get_tree().change_scene_to_file("res://ui/Garage.tscn")

func _on_profile_pressed():
	get_tree().change_scene_to_file("res://ui/Profile.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://ui/Settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
