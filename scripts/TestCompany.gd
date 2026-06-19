extends Node

func _ready():
	print("--- Starting Company System Test ---")
	test_hiring()
	test_assignment()
	test_passive_income()
	print("--- Company System Test Complete ---")
	get_tree().quit()

func test_hiring():
	print("Testing Hiring...")
	var initial_money = GameManager.money
	var initial_hired_count = GameManager.hired_drivers.size()
	var initial_pool_count = GameManager.driver_pool.size()

	if GameManager.hire_driver(0):
		assert(GameManager.money == initial_money - GameManager.HIRING_COST)
		assert(GameManager.hired_drivers.size() == initial_hired_count + 1)
		# Pool should be refilled if it was small, or just reduced
		print("Hiring successful.")
	else:
		print("Hiring failed (likely not enough money).")

func test_assignment():
	print("Testing Assignment...")
	if GameManager.hired_drivers.is_empty():
		print("No drivers to assign.")
		return

	var driver_id = GameManager.hired_drivers.keys()[0]
	var truck_id = "bedford_rocket"

	if GameManager.assign_driver_to_truck(driver_id, truck_id):
		assert(GameManager.hired_drivers[driver_id].assigned_truck == truck_id)
		print("Assignment successful.")
	else:
		print("Assignment failed.")

func test_passive_income():
	print("Testing Passive Income...")
	var initial_money = GameManager.money
	GameManager.process_daily_income()

	if GameManager.money != initial_money:
		print("Money changed after daily income: ", GameManager.money)
	else:
		print("Money did not change (might be zero net profit).")

	assert(GameManager.daily_profit_history.size() > 0)
	print("Daily report generated: ", GameManager.daily_profit_history.back())
