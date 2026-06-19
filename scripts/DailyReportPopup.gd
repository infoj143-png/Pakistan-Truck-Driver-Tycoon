extends Control

@onready var income_label = %Income
@onready var salaries_label = %Salaries
@onready var reputation_label = %Reputation
@onready var net_profit_label = %NetProfit

func setup(report: Dictionary):
	income_label.text = "Gross Income: Rs. " + str(report.income)
	salaries_label.text = "Salaries Paid: Rs. " + str(report.salaries)
	reputation_label.text = "Reputation Change: " + ("+" if report.rep_change >= 0 else "") + str(report.rep_change)
	net_profit_label.text = "Net Profit: Rs. " + str(report.net_profit)

	if report.net_profit >= 0:
		net_profit_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		net_profit_label.add_theme_color_override("font_color", Color.RED)

func _on_close_pressed():
	queue_free()
