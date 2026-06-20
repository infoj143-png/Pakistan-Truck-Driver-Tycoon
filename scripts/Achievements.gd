extends Control

@onready var achievement_list = $VBoxContainer/ScrollContainer/AchievementList
@onready var background = %Background
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	background.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["dark_bg"], GameManager.TRUCK_ART_COLORS["orange"]))
	back_button.add_theme_stylebox_override("normal", GameManager.get_truck_art_stylebox(GameManager.TRUCK_ART_COLORS["blue"], GameManager.TRUCK_ART_COLORS["yellow"], 2))
	update_ui()

func update_ui():
	for child in achievement_list.get_children():
		child.queue_free()

	for id in GameManager.ACHIEVEMENTS:
		var ach = GameManager.ACHIEVEMENTS[id]
		var unlocked = GameManager.unlocked_achievements.has(id)
		var progress = GameManager.achievement_progress.get(id, 0)

		var panel = PanelContainer.new()
		panel.add_theme_stylebox_override("panel", GameManager.get_truck_art_stylebox(
			GameManager.TRUCK_ART_COLORS["blue"] if not unlocked else GameManager.TRUCK_ART_COLORS["green"],
			GameManager.TRUCK_ART_COLORS["yellow"] if not unlocked else GameManager.TRUCK_ART_COLORS["white"],
			2
		))

		var hbox = HBoxContainer.new()
		panel.add_child(hbox)

		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)

		var name_label = Label.new()
		name_label.text = ach["name"] + ( " [UNLOCKED]" if unlocked else "" )
		name_label.add_theme_font_size_override("font_size", 20)
		info_vbox.add_child(name_label)

		var desc_label = Label.new()
		desc_label.text = ach["description"]
		info_vbox.add_child(desc_label)

		var progress_label = Label.new()
		progress_label.text = "Progress: " + str(progress) + " / " + str(ach["goal"])
		info_vbox.add_child(progress_label)

		# Badge Icon
		var badge = TextureRect.new()
		badge.texture = load("res://icon.svg")
		badge.custom_minimum_size = Vector2(64, 64)
		badge.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		badge.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		badge.self_modulate = GameManager.TRUCK_ART_COLORS["yellow"] if unlocked else Color.GRAY
		hbox.add_child(badge)

		var reward_vbox = VBoxContainer.new()
		hbox.add_child(reward_vbox)

		var reward_title = Label.new()
		reward_title.text = "Reward:"
		reward_vbox.add_child(reward_title)

		if ach.has("reward_money"):
			var r = Label.new()
			r.text = "Rs. " + str(ach["reward_money"])
			reward_vbox.add_child(r)
		if ach.has("reward_xp"):
			var r = Label.new()
			r.text = str(ach["reward_xp"]) + " XP"
			reward_vbox.add_child(r)
		if ach.has("reward_skin"):
			var r = Label.new()
			r.text = "Skin: " + GameManager.SKINS[ach["reward_skin"]]["name"]
			reward_vbox.add_child(r)

		if unlocked:
			panel.modulate = Color.GREEN

		achievement_list.add_child(panel)

func _on_back_button_pressed():
	GameManager.goto_scene("res://ui/MainMenu.tscn")
