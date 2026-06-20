extends PanelContainer

signal buy_pressed(truck_id)
signal select_pressed(truck_id)
signal upgrade_pressed(truck_id, stat_id)

var truck_id: String

@onready var name_label = %NameLabel
@onready var price_label = %PriceLabel
@onready var buy_button = %BuyButton
@onready var select_button = %SelectButton

# Stat labels
@onready var speed_val = %SpeedValue
@onready var fuel_val = %FuelValue
@onready var cargo_val = %CargoValue
@onready var durability_val = %DurabilityValue

# Stat progress bars
@onready var speed_bar = %SpeedBar
@onready var fuel_bar = %FuelBar
@onready var cargo_bar = %CargoBar
@onready var durability_bar = %DurabilityBar

# Upgrade buttons
@onready var upgrade_speed_btn = %UpgradeSpeedBtn
@onready var upgrade_fuel_btn = %UpgradeFuelBtn
@onready var upgrade_cargo_btn = %UpgradeCargoBtn
@onready var upgrade_durability_btn = %UpgradeDurabilityBtn

@onready var condition_label = Label.new()
@onready var repair_button = Button.new()

func setup(_truck_id: String):
	self.truck_id = _truck_id
	update_ui()

func update_ui():
	var data = GameManager.TRUCK_DATA[truck_id]
	var owned = GameManager.owned_trucks.has(truck_id)
	var selected = GameManager.selected_truck == truck_id
	var stats = GameManager.get_truck_stats(truck_id)
	var upgrades = GameManager.owned_trucks.get(truck_id, {"speed": 0, "fuel": 0, "cargo": 0, "durability": 0})

	name_label.text = data["name"]

	speed_val.text = str(int(stats["speed"]))
	fuel_val.text = str(int(stats["fuel"]))
	cargo_val.text = str(stats["cargo"]) + "x"
	durability_val.text = str(int(stats["durability"]))

	if owned:
		price_label.text = "OWNED"
		buy_button.hide()
		select_button.show()
		select_button.disabled = selected
		select_button.text = "SELECTED" if selected else "SELECT"

		# Condition and Repair
		var condition = GameManager.owned_trucks[truck_id].get("condition", 100.0)
		condition_label.text = "Condition: " + str(int(condition)) + "%"
		if not condition_label.get_parent():
			get_node("VBoxContainer").add_child(condition_label)

		var repair_cost = int((100.0 - condition) * 50)
		repair_button.text = "Repair (Rs. " + str(repair_cost) + ")"
		repair_button.visible = condition < 100.0
		repair_button.disabled = GameManager.money < repair_cost
		if not repair_button.get_parent():
			repair_button.pressed.connect(_on_repair_pressed)
			get_node("VBoxContainer").add_child(repair_button)

		# Update bars and upgrade buttons
		_update_stat_row(speed_bar, upgrade_speed_btn, "speed", upgrades["speed"], data["upgrade_costs"]["speed"])
		_update_stat_row(fuel_bar, upgrade_fuel_btn, "fuel", upgrades["fuel"], data["upgrade_costs"]["fuel"])
		_update_stat_row(cargo_bar, upgrade_cargo_btn, "cargo", upgrades["cargo"], data["upgrade_costs"]["cargo"])
		_update_stat_row(durability_bar, upgrade_durability_btn, "durability", upgrades["durability"], data["upgrade_costs"]["durability"])
	else:
		price_label.text = "Rs. " + str(data["price"])
		buy_button.show()
		select_button.hide()

		# Show base stats in bars (0% progress for unowned)
		speed_bar.value = 0
		fuel_bar.value = 0
		cargo_bar.value = 0
		durability_bar.value = 0

		# Hide upgrade buttons for unowned trucks
		upgrade_speed_btn.hide()
		upgrade_fuel_btn.hide()
		upgrade_cargo_btn.hide()
		upgrade_durability_btn.hide()

func _update_stat_row(bar: ProgressBar, btn: Button, stat_id: String, level: int, base_cost: int):
	bar.value = (level / 5.0) * 100
	btn.show()
	if level >= 5:
		btn.text = "MAX"
		btn.disabled = true
	else:
		var cost = base_cost * (level + 1)
		btn.text = "UP (Rs. " + str(cost) + ")"
		btn.disabled = GameManager.money < cost

func _on_buy_button_pressed():
	buy_pressed.emit(truck_id)

func _on_select_button_pressed():
	select_pressed.emit(truck_id)

func _on_upgrade_speed_btn_pressed():
	upgrade_pressed.emit(truck_id, "speed")

func _on_upgrade_fuel_btn_pressed():
	upgrade_pressed.emit(truck_id, "fuel")

func _on_upgrade_cargo_btn_pressed():
	upgrade_pressed.emit(truck_id, "cargo")

func _on_upgrade_durability_btn_pressed():
	upgrade_pressed.emit(truck_id, "durability")

func _on_repair_pressed():
	if GameManager.repair_truck(truck_id):
		update_ui()
