extends Control

@onready var money_label = %MoneyLabel
@onready var reputation_label = %ReputationLabel
@onready var driver_label = %DriverLabel
@onready var fleet_label = %FleetLabel

func _ready():
	GameManager.stats_changed.connect(update_ui)
	update_ui()

func update_ui():
	money_label.text = "Balance: Rs. " + str(GameManager.money)
	reputation_label.text = "Reputation: " + str(GameManager.company_reputation) + "/100"
	driver_label.text = "Drivers: " + str(GameManager.hired_drivers.size())
	fleet_label.text = "Fleet Size: " + str(GameManager.owned_trucks.size())

func _on_hiring_hall_pressed():
	get_tree().change_scene_to_file("res://ui/HiringHall.tscn")

func _on_fleet_management_pressed():
	get_tree().change_scene_to_file("res://ui/FleetManagement.tscn")

func _on_daily_reports_pressed():
	# For simplicity, we can show the last report or a list
	if GameManager.daily_profit_history.is_empty():
		print("No reports yet.")
		return

	# Ideally, instantiate a DailyReportPopup
	var popup_scene = load("res://ui/DailyReportPopup.tscn")
	if popup_scene:
		var popup = popup_scene.instantiate()
		add_child(popup)
		popup.setup(GameManager.daily_profit_history.back())

func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
