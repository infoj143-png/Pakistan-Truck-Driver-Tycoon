extends Control

func _on_back_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")

func _on_start_mission_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/World.tscn")
