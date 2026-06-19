extends Control

@onready var balance_label = %BalanceLabel
@onready var active_loans_list = %ActiveLoansList

func _ready():
	GameManager.stats_changed.connect(update_ui)
	update_ui()

func update_ui():
	balance_label.text = "Balance: Rs. " + str(GameManager.money)

	# Clear active loans list
	for child in active_loans_list.get_children():
		child.queue_free()

	# Populate active loans
	for i in range(GameManager.active_loans.size()):
		var loan = GameManager.active_loans[i]
		var hbox = HBoxContainer.new()
		var info = Label.new()
		var remaining_total = int(loan.amount * (1.0 + loan.interest_rate) * (loan.remaining_installments / 10.0))
		info.text = "Loan: Rs. " + str(loan.amount) + " (" + str(loan.remaining_installments) + " left) - Total: Rs. " + str(remaining_total)
		hbox.add_child(info)

		var repay_btn = Button.new()
		repay_btn.text = "Repay Full"
		repay_btn.disabled = GameManager.money < remaining_total
		repay_btn.pressed.connect(_on_repay_loan_pressed.bind(i))
		hbox.add_child(repay_btn)

		active_loans_list.add_child(hbox)

func _on_take_loan_pressed(amount: int):
	AudioManager.play_ui_click()
	GameManager.take_loan(amount)
	print("Took loan: ", amount)

func _on_repay_loan_pressed(index: int):
	AudioManager.play_ui_click()
	if GameManager.repay_loan(index):
		print("Repaid loan at index: ", index)

func _on_back_pressed():
	AudioManager.play_ui_click()
	get_tree().change_scene_to_file("res://ui/CompanyDashboard.tscn")
