extends Control

@onready var driver_list = %DriverList
@onready var money_label = %MoneyLabel

func _ready():
	GameManager.stats_changed.connect(update_ui)
	update_ui()

func update_ui():
	money_label.text = "Rs. " + str(GameManager.money)

	for child in driver_list.get_children():
		child.queue_free()

	for i in range(GameManager.driver_pool.size()):
		var driver = GameManager.driver_pool[i]
		var container = HBoxContainer.new()

		var info_vbox = VBoxContainer.new()
		var name_label = Label.new()
		name_label.text = driver.name + " (Lvl " + str(driver.level) + ")"
		info_vbox.add_child(name_label)

		var stats_label = Label.new()
		stats_label.text = "Eff: %.1f | Spd: %.1f | Rel: %.1f" % [driver.skills.efficiency, driver.skills.speed, driver.skills.reliability]
		stats_label.add_theme_font_size_override("font_size", 14)
		info_vbox.add_child(stats_label)

		var salary_label = Label.new()
		salary_label.text = "Salary: Rs. " + str(driver.salary) + "/day"
		salary_label.add_theme_font_size_override("font_size", 14)
		info_vbox.add_child(salary_label)

		container.add_child(info_vbox)
		info_vbox.size_flags_horizontal = SIZE_EXPAND_FILL

		var hire_button = Button.new()
		hire_button.text = "Hire (Rs. " + str(GameManager.HIRING_COST) + ")"
		hire_button.pressed.connect(_on_hire_pressed.bind(i))
		container.add_child(hire_button)

		driver_list.add_child(container)

func _on_hire_pressed(index):
	if GameManager.hire_driver(index):
		print("Hired driver!")
	else:
		print("Not enough money!")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/CompanyDashboard.tscn")
