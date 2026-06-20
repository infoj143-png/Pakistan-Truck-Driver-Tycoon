extends Control

func _ready():
	$Timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	GameManager.goto_scene("res://ui/MainMenu.tscn")
