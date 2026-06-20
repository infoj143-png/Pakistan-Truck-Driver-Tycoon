extends Control

@onready var truck_list = %TruckList
@onready var money_label = %MoneyLabel
@onready var truck_preview = %TruckPreview
@onready var skin_list = %SkinList
@onready var skin_panel = %SkinPanel
@onready var back_button = %Back

var truck_card_scene = preload("res://ui/TruckCard.tscn")

func _ready():
	skin_panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["blue"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
	back_button.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["red"], GameManager.TRUCK_ART_COLORS["white"], 2))

	GameManager.stats_changed.connect(update_ui)
	GameManager.skin_changed.connect(_on_skin_changed)
	update_ui()
	update_skin_list()
	_update_preview()

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
		_update_preview()

func _update_preview():
	if truck_preview:
		truck_preview.self_modulate = GameManager.SKINS[GameManager.selected_skin]["color"]

func update_skin_list():
	for child in skin_list.get_children():
		child.queue_free()

	for skin_id in GameManager.SKINS:
		var btn = Button.new()
		var skin_data = GameManager.SKINS[skin_id]
		var unlocked = GameManager.unlocked_skins.has(skin_id)

		btn.text = skin_data["name"]
		btn.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["blue"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
		btn.add_theme_stylebox_override("hover", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["orange"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
		btn.add_theme_stylebox_override("disabled", GameManager.get_truck_art_stylebox(Color(0.3, 0.3, 0.3), Color(0.5, 0.5, 0.5), 2))

		if not unlocked:
			btn.text += " (LOCKED)"
			btn.disabled = true

		if skin_id == GameManager.selected_skin:
			btn.text += " [EQUIPPED]"
			btn.disabled = true

		btn.pressed.connect(_on_skin_selected.bind(skin_id))
		skin_list.add_child(btn)

func _on_skin_selected(skin_id: String):
	AudioManager.play_ui_click()
	GameManager.set_selected_skin(skin_id)
	update_skin_list()

func _on_skin_changed(_skin_id):
	_update_preview()

func _on_truck_upgrade_pressed(truck_id, stat_id):
	AudioManager.play_ui_click()
	if GameManager.upgrade_truck(truck_id, stat_id):
		print("Upgraded ", stat_id, " for ", truck_id)

func _on_back_pressed():
	AudioManager.play_ui_click()
	GameManager.goto_scene("res://ui/MainMenu.tscn")
