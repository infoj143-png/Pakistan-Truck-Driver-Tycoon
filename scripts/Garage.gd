extends Control

@onready var truck_list = %TruckList
@onready var money_label = %MoneyLabel

var truck_card_scene = preload("res://ui/TruckCard.tscn")

func _ready():
	GameManager.stats_changed.connect(update_ui)
	update_ui()

func update_ui():
	money_label.text = "Rs. " + str(GameManager.money)

	# Clear existing cards
	for child in truck_list.get_children():
		child.queue_free()

	# Create new cards
	for truck_id in GameManager.TRUCK_DATA:
		var card = truck_card_scene.instantiate()
		truck_list.add_child(card)
		card.setup(truck_id)
		card.buy_pressed.connect(_on_truck_buy_pressed)
		card.select_pressed.connect(_on_truck_select_pressed)
		card.upgrade_pressed.connect(_on_truck_upgrade_pressed)

func _on_truck_buy_pressed(truck_id):
	AudioManager.play_ui_click()
	if GameManager.buy_truck(truck_id):
		print("Bought truck: ", truck_id)

func _on_truck_select_pressed(truck_id):
	AudioManager.play_ui_click()
	if GameManager.select_truck(truck_id):
		print("Selected truck: ", truck_id)

func _on_truck_upgrade_pressed(truck_id, stat_id):
	AudioManager.play_ui_click()
	if GameManager.upgrade_truck(truck_id, stat_id):
		print("Upgraded ", stat_id, " for ", truck_id)

func _on_back_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
