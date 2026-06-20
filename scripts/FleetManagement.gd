extends Control

@onready var truck_list = %TruckList

func _ready():
	update_ui()

func update_ui():
	for child in truck_list.get_children():
		child.queue_free()

	for truck_id in GameManager.owned_trucks:
		var truck_info = GameManager.TRUCK_DATA[truck_id]
		var container = HBoxContainer.new()

		var label = Label.new()
		label.text = truck_info.name
		label.size_flags_horizontal = SIZE_EXPAND_FILL
		container.add_child(label)

		var option_button = OptionButton.new()
		option_button.add_item("No Driver", 0)
		option_button.set_meta("truck_id", truck_id)

		var current_driver_id = ""
		# Find if anyone is assigned to this truck
		for d_id in GameManager.hired_drivers:
			if GameManager.hired_drivers[d_id].assigned_truck == truck_id:
				current_driver_id = d_id
				break

		var available_drivers = []
		for d_id in GameManager.hired_drivers:
			var driver = GameManager.hired_drivers[d_id]
			if driver.assigned_truck == "" or driver.assigned_truck == truck_id:
				available_drivers.append(d_id)
				option_button.add_item(driver.name, available_drivers.size())
				if d_id == current_driver_id:
					option_button.select(available_drivers.size())

		option_button.item_selected.connect(_on_driver_selected.bind(option_button, available_drivers))
		container.add_child(option_button)

		truck_list.add_child(container)

func _on_driver_selected(index, option_button, available_drivers):
	var truck_id = option_button.get_meta("truck_id")
	if index == 0:
		# Find current driver and unassign
		for d_id in GameManager.hired_drivers:
			if GameManager.hired_drivers[d_id].assigned_truck == truck_id:
				GameManager.assign_driver_to_truck(d_id, "")
				break
	else:
		var driver_id = available_drivers[index - 1]
		GameManager.assign_driver_to_truck(driver_id, truck_id)

	update_ui()

func _on_back_pressed():
	GameManager.goto_scene("res://ui/CompanyDashboard.tscn")
