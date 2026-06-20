extends Control

@onready var reward_grid = $VBoxContainer/RewardGrid
@onready var claim_button = $VBoxContainer/ClaimButton
@onready var info_label = $VBoxContainer/InfoLabel

func _ready():
	update_ui()

func update_ui():
	# Clear existing children if any (in case of refresh)
	for child in reward_grid.get_children():
		child.queue_free()

	var day_reached = GameManager.consecutive_logins
	var claimed = GameManager.reward_claimed_today

	for i in range(GameManager.DAILY_REWARDS.size()):
		var reward = GameManager.DAILY_REWARDS[i]
		var day_num = i + 1

		var panel = PanelContainer.new()
		var vbox = VBoxContainer.new()
		panel.add_child(vbox)

		var day_label = Label.new()
		day_label.text = "Day " + str(day_num)
		day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(day_label)

		var reward_label = Label.new()
		if reward.type == "money":
			reward_label.text = "Rs. " + str(reward.amount)
		elif reward.type == "xp":
			reward_label.text = str(reward.amount) + " XP"
		elif reward.type == "skin":
			reward_label.text = "SKIN: " + reward.name
		reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(reward_label)

		if day_num < day_reached:
			panel.modulate = Color.GREEN # Already claimed in previous days
		elif day_num == day_reached:
			if claimed:
				panel.modulate = Color.GREEN
			else:
				panel.modulate = Color.YELLOW # To be claimed today
		else:
			panel.modulate = Color.WHITE # Future rewards

		reward_grid.add_child(panel)

	claim_button.disabled = claimed
	if claimed:
		info_label.text = "Reward claimed! Come back tomorrow."
	else:
		info_label.text = "Claim your Day " + str(day_reached) + " reward!"

func _on_claim_button_pressed():
	if GameManager.claim_daily_reward():
		update_ui()

func _on_back_button_pressed():
	GameManager.goto_scene("res://ui/MainMenu.tscn")
