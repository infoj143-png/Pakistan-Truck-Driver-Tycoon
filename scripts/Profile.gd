extends Control

@onready var money_label = $VBoxContainer/MoneyLabel
@onready var xp_label = $VBoxContainer/XPLabel
@onready var level_label = $VBoxContainer/LevelLabel

func _ready():
	update_ui()
	GameManager.stats_changed.connect(update_ui)

func update_ui():
	money_label.text = "Money: $" + str(GameManager.money)
	xp_label.text = "XP: " + str(GameManager.xp)
	level_label.text = "Level: " + str(GameManager.level)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
