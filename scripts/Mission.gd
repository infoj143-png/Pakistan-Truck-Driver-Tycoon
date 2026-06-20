extends Control

func _on_back_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/MainMenu.tscn")

func _on_start_mission_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://scenes/World.tscn")
