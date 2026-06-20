extends Control

@onready var income_label = %Income
@onready var salaries_label = %Salaries
@onready var reputation_label = %Reputation
@onready var net_profit_label = %NetProfit

@onready var maintenance_label = Label.new()
@onready var loans_label = Label.new()
@onready var event_label = Label.new()

func setup(report: Dictionary):
	income_label.text = "Gross Income: Rs. " + str(report["income"])
	salaries_label.text = "Salaries Paid: Rs. " + str(report["salaries"])

	var details_container = get_node("%Details") if has_node("%Details") else income_label.get_parent()

	if report.has("maintenance"):
		maintenance_label.text = "Maintenance: Rs. " + str(report["maintenance"])
		if not maintenance_label.get_parent():
			details_container.add_child(maintenance_label)

	if report.has("loans"):
		loans_label.text = "Loan Repayments: Rs. " + str(report["loans"])
		if not loans_label.get_parent():
			details_container.add_child(loans_label)

	if report.has("event"):
		event_label.text = "Market: " + report["event"]
		if not event_label.get_parent():
			details_container.add_child(event_label)

	reputation_label.text = "Reputation Change: " + ("+" if report["rep_change"] >= 0 else "") + str(report["rep_change"])
	net_profit_label.text = "Net Profit: Rs. " + str(report["net_profit"])

	if report["net_profit"] >= 0:
		net_profit_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		net_profit_label.add_theme_color_override("font_color", Color.RED)

func _on_close_pressed():
	queue_free()
