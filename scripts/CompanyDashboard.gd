extends Control

@onready var money_label = %MoneyLabel
@onready var reputation_label = %ReputationLabel
@onready var driver_label = %DriverLabel
@onready var fleet_label = %FleetLabel

@onready var fuel_price_label = Label.new()
@onready var event_label = Label.new()
@onready var loan_label = Label.new()

func _ready():
	GameManager.stats_changed.connect(update_ui)
	update_ui()

func update_ui():
	money_label.text = "Balance: Rs. " + str(GameManager.money)
	reputation_label.text = "Reputation: " + str(GameManager.company_reputation) + "/100"
	driver_label.text = "Drivers: " + str(GameManager.hired_drivers.size())
	fleet_label.text = "Fleet Size: " + str(GameManager.owned_trucks.size())

	fuel_price_label.text = "Fuel Price: Rs. " + str(int(GameManager.base_fuel_price)) + "/L"
	if not fuel_price_label.get_parent():
		%StatsContainer.add_child(fuel_price_label)

	event_label.text = "Market: " + GameManager.active_economic_event["name"]
	if not event_label.get_parent():
		%StatsContainer.add_child(event_label)

	var total_debt = 0
	for loan in GameManager.active_loans:
		total_debt += int(loan["amount"] * (1.0 + loan["interest_rate"]) * (loan["remaining_installments"] / 10.0))
	loan_label.text = "Total Debt: Rs. " + str(total_debt)
	if not loan_label.get_parent():
		%StatsContainer.add_child(loan_label)

func _on_hiring_hall_pressed():
	GameManager.goto_scene("res://ui/HiringHall.tscn")

func _on_fleet_management_pressed():
	GameManager.goto_scene("res://ui/FleetManagement.tscn")

func _on_bank_pressed():
	GameManager.goto_scene("res://ui/Bank.tscn")

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
	GameManager.goto_scene("res://ui/MainMenu.tscn")
