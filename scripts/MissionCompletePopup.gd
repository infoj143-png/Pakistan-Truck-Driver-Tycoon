extends Control

@onready var money_text = $Panel/VBoxContainer/MoneyText
@onready var xp_text = $Panel/VBoxContainer/XPText

func _ready():
	hide()
	GameManager.mission_completed.connect(_on_mission_completed)

func show_reward(money, xp):
	if money_text:
		money_text.text = "Money Earned: Rs. " + str(money)
	if xp_text:
		xp_text.text = "XP Earned: " + str(xp)
	show()

func _on_mission_completed(money, xp):
	show_reward(money, xp)

func _on_continue_pressed():
	hide()
	GameManager.goto_scene("res://ui/MainMenu.tscn")
