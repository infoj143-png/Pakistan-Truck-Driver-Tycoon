extends CanvasLayer

@onready var money_label = $Control/HBoxContainer/MoneyLabel
@onready var xp_label = $Control/HBoxContainer/XPLabel
@onready var fuel_bar = $Control/FuelContainer/ProgressBar

func _ready():
	GameManager.stats_changed.connect(update_ui)
	update_ui()

func update_ui():
	money_label.text = "Money: $" + str(GameManager.money)
	xp_label.text = "XP: " + str(GameManager.xp) + " (Lvl " + str(GameManager.level) + ")"

	# Try to find truck in scene to update fuel
	var truck = get_tree().get_first_node_in_group("truck")
	if truck:
		fuel_bar.value = truck.fuel
	else:
		fuel_bar.value = GameManager.fuel
