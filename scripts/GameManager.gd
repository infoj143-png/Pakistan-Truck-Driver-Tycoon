extends Node

const SAVE_PATH = "user://save_game.dat"

# Player Stats
var money: int = 1000
var xp: int = 0
var level: int = 1
var fuel: float = 100.0

# Company Stats
var hired_drivers: Dictionary = {} # id -> {name, level, xp, salary, skills: {efficiency, speed, reliability}, assigned_truck}
var driver_pool: Array = []
var company_reputation: int = 50
var daily_profit_history: Array = []
var game_day_timer: float = 120.0

# Economy Stats
var active_loans: Array = [] # {amount, remaining_installments, interest_rate}
var base_fuel_price: float = 150.0
var daily_expenses_base: int = 200
var active_economic_event: Dictionary = {"name": "Stable Economy", "reward_mult": 1.0, "fuel_price_mult": 1.0}

const BASE_PASSIVE_INCOME = 500
const HIRING_COST = 1000
const DRIVER_SALARY_BASE = 200
const PAKISTANI_NAMES = ["Ahmed", "Khan", "Iqbal", "Ali", "Malik", "Zubair", "Bilal", "Hassan", "Umer", "Farooq"]

# Truck Data
const TRUCK_DATA = {
	"bedford_rocket": {
		"name": "Bedford Rocket",
		"price": 0,
		"base_stats": {
			"speed": 300.0,
			"fuel": 100.0,
			"cargo": 1.0,
			"durability": 100.0
		},
		"upgrade_costs": {
			"speed": 500,
			"fuel": 400,
			"cargo": 600,
			"durability": 300
		}
	},
	"hino_king": {
		"name": "Hino King",
		"price": 5000,
		"base_stats": {
			"speed": 350.0,
			"fuel": 150.0,
			"cargo": 1.5,
			"durability": 150.0
		},
		"upgrade_costs": {
			"speed": 1000,
			"fuel": 800,
			"cargo": 1200,
			"durability": 600
		}
	},
	"isuzu_titan": {
		"name": "Isuzu Titan",
		"price": 12000,
		"base_stats": {
			"speed": 400.0,
			"fuel": 200.0,
			"cargo": 2.0,
			"durability": 200.0
		},
		"upgrade_costs": {
			"speed": 2000,
			"fuel": 1500,
			"cargo": 2500,
			"durability": 1200
		}
	}
}

var owned_trucks: Dictionary = {
	"bedford_rocket": {"speed": 0, "fuel": 0, "cargo": 0, "durability": 0, "condition": 100.0}
}
var selected_truck: String = "bedford_rocket"

# City Progression
var cities = {
	"Lahore": {"unlock_level": 1, "reward_mult": 1.0, "fuel_mult": 1.0, "difficulty": 1},
	"Karachi": {"unlock_level": 3, "reward_mult": 1.2, "fuel_mult": 1.1, "difficulty": 2},
	"Islamabad": {"unlock_level": 5, "reward_mult": 1.5, "fuel_mult": 1.2, "difficulty": 2},
	"Multan": {"unlock_level": 7, "reward_mult": 1.8, "fuel_mult": 1.3, "difficulty": 3},
	"Faisalabad": {"unlock_level": 10, "reward_mult": 2.2, "fuel_mult": 1.4, "difficulty": 3},
	"Peshawar": {"unlock_level": 12, "reward_mult": 2.5, "fuel_mult": 1.5, "difficulty": 4},
	"Quetta": {"unlock_level": 15, "reward_mult": 3.0, "fuel_mult": 1.7, "difficulty": 5},
	"Hunza": {"unlock_level": 20, "reward_mult": 4.0, "fuel_mult": 2.0, "difficulty": 6}
}

var current_city: String = "Lahore"
var unlocked_cities: Array = ["Lahore"]

signal stats_changed
signal mission_completed(reward_money, reward_xp)
signal daily_report_generated(report_data)

func _ready():
	load_game()
	if driver_pool.is_empty():
		generate_driver_pool()

func _process(delta):
	game_day_timer -= delta
	if game_day_timer <= 0:
		process_daily_income()
		game_day_timer = 120.0

func add_money(amount: int):
	money += amount
	stats_changed.emit()
	save_game()

func add_xp(amount: int):
	xp += amount
	_check_level_up()
	stats_changed.emit()
	save_game()

func complete_mission(reward_money: int, reward_xp: int):
	add_money(reward_money)
	add_xp(reward_xp)
	mission_completed.emit(reward_money, reward_xp)

func buy_truck(truck_id: String):
	if not TRUCK_DATA.has(truck_id):
		return false

	var price = TRUCK_DATA[truck_id].price
	if money >= price and not owned_trucks.has(truck_id):
		money -= price
		owned_trucks[truck_id] = {"speed": 0, "fuel": 0, "cargo": 0, "durability": 0, "condition": 100.0}
		stats_changed.emit()
		save_game()
		return true
	return false

func select_truck(truck_id: String):
	if owned_trucks.has(truck_id):
		selected_truck = truck_id
		stats_changed.emit()
		save_game()
		return true
	return false

func upgrade_truck(truck_id: String, stat_id: String):
	if not owned_trucks.has(truck_id) or not TRUCK_DATA.has(truck_id):
		return false

	var current_level = owned_trucks[truck_id][stat_id]
	if current_level >= 5: # Max level 5
		return false

	var base_cost = TRUCK_DATA[truck_id].upgrade_costs[stat_id]
	var cost = base_cost * (current_level + 1)

	if money >= cost:
		money -= cost
		owned_trucks[truck_id][stat_id] += 1
		stats_changed.emit()
		save_game()
		return true
	return false

func get_truck_stats(truck_id: String):
	if not TRUCK_DATA.has(truck_id):
		return null

	var base_stats = TRUCK_DATA[truck_id].base_stats
	var stats = base_stats.duplicate()

	if owned_trucks.has(truck_id):
		var upgrades = owned_trucks[truck_id]
		# Each upgrade level adds 10% to the base stat
		stats.speed += base_stats.speed * (upgrades.speed * 0.1)
		stats.fuel += base_stats.fuel * (upgrades.fuel * 0.1)
		stats.cargo += base_stats.cargo * (upgrades.cargo * 0.1)
		stats.durability += base_stats.durability * (upgrades.durability * 0.1)

	return stats

func _check_level_up():
	var xp_needed = level * 100 # Simple level up logic
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = level * 100
		print("Level Up! Current Level: ", level)
		_unlock_cities_for_level()

func _unlock_cities_for_level():
	for city_name in cities:
		if cities[city_name].unlock_level <= level:
			if not city_name in unlocked_cities:
				unlocked_cities.append(city_name)
				print("Unlocked City: ", city_name)

# Company Management Functions
func generate_driver_pool():
	driver_pool.clear()
	for i in range(3):
		var driver = {
			"id": str(Time.get_unix_time_from_system()) + "_" + str(i),
			"name": PAKISTANI_NAMES[randi() % PAKISTANI_NAMES.size()],
			"level": 1,
			"xp": 0,
			"salary": DRIVER_SALARY_BASE + (randi() % 50),
			"skills": {
				"efficiency": 0.8 + (randf() * 0.4),
				"speed": 0.8 + (randf() * 0.4),
				"reliability": 0.8 + (randf() * 0.4)
			},
			"assigned_truck": ""
		}
		driver_pool.append(driver)
	save_game()

func hire_driver(pool_index: int):
	if pool_index < 0 or pool_index >= driver_pool.size():
		return false

	if money >= HIRING_COST:
		money -= HIRING_COST
		var driver = driver_pool[pool_index]
		hired_drivers[driver.id] = driver
		driver_pool.remove_at(pool_index)

		# Refill pool if empty
		if driver_pool.is_empty():
			generate_driver_pool()

		stats_changed.emit()
		save_game()
		return true
	return false

func fire_driver(driver_id: String):
	if hired_drivers.has(driver_id):
		hired_drivers.erase(driver_id)
		stats_changed.emit()
		save_game()
		return true
	return false

func assign_driver_to_truck(driver_id: String, truck_id: String):
	if not hired_drivers.has(driver_id):
		return false

	# If truck_id is empty, unassign
	if truck_id == "":
		hired_drivers[driver_id].assigned_truck = ""
		save_game()
		return true

	if not owned_trucks.has(truck_id):
		return false

	# Ensure no other driver is assigned to this truck
	for id in hired_drivers:
		if hired_drivers[id].assigned_truck == truck_id:
			hired_drivers[id].assigned_truck = ""

	hired_drivers[driver_id].assigned_truck = truck_id
	save_game()
	return true

func process_daily_income():
	var total_income = 0
	var total_salaries = 0
	var total_maintenance = 0
	var total_loan_repayments = 0
	var daily_rep_change = 0

	# Economic event effects
	var event_reward_mult = active_economic_event.get("reward_mult", 1.0)

	# Drivers and Passive Income
	for driver_id in hired_drivers:
		var driver = hired_drivers[driver_id]
		total_salaries += driver.salary

		if driver.assigned_truck != "":
			var truck_stats = get_truck_stats(driver.assigned_truck)
			var truck_data = owned_trucks[driver.assigned_truck]

			if truck_stats:
				# Maintenance cost based on condition
				var maintenance = int((100.0 - truck_data.condition) * 2)
				total_maintenance += maintenance

				var income = int(BASE_PASSIVE_INCOME * driver.skills.efficiency * truck_stats.cargo * event_reward_mult)
				total_income += income

				# Reliability check - random chance to lose reputation or income if unreliable
				if randf() > driver.skills.reliability:
					daily_rep_change -= 1
				else:
					daily_rep_change += 1
		else:
			# Unassigned drivers still take salary but don't earn much, and reputation might drop
			daily_rep_change -= 1

	# Loan Repayments
	var remaining_loans = []
	for loan in active_loans:
		var installment = int((loan.amount * (1.0 + loan.interest_rate)) / 10.0) # 10 installments
		total_loan_repayments += installment
		loan.remaining_installments -= 1
		if loan.remaining_installments > 0:
			remaining_loans.append(loan)
	active_loans = remaining_loans

	var total_expenses = total_salaries + total_maintenance + total_loan_repayments + daily_expenses_base
	var net_profit = total_income - total_expenses

	money += net_profit
	company_reputation = clampi(company_reputation + daily_rep_change, 0, 100)

	var report = {
		"date": Time.get_datetime_dict_from_system(),
		"income": total_income,
		"salaries": total_salaries,
		"maintenance": total_maintenance,
		"loans": total_loan_repayments,
		"expenses": total_expenses,
		"net_profit": net_profit,
		"rep_change": daily_rep_change,
		"event": active_economic_event.name
	}

	daily_profit_history.append(report)
	if daily_profit_history.size() > 30:
		daily_profit_history.remove_at(0)

	# Trigger new economic event for the next day
	trigger_economic_event()

	daily_report_generated.emit(report)
	stats_changed.emit()
	save_game()

func trigger_economic_event():
	var events = [
		{"name": "Stable Economy", "reward_mult": 1.0, "fuel_price_mult": 1.0},
		{"name": "Economic Boom", "reward_mult": 1.5, "fuel_price_mult": 1.2},
		{"name": "Fuel Crisis", "reward_mult": 0.8, "fuel_price_mult": 2.5},
		{"name": "Logistics Strike", "reward_mult": 0.5, "fuel_price_mult": 0.9},
		{"name": "Tech Breakthrough", "reward_mult": 1.2, "fuel_price_mult": 0.7}
	]

	active_economic_event = events[randi() % events.size()]
	base_fuel_price = 150.0 * active_economic_event.fuel_price_mult
	print("New Economic Event: ", active_economic_event.name)

func take_loan(amount: int):
	var interest_rate = 0.1 # 10% interest
	if amount > 10000: interest_rate = 0.15

	var loan = {
		"amount": amount,
		"remaining_installments": 10,
		"interest_rate": interest_rate
	}
	active_loans.append(loan)
	money += amount
	stats_changed.emit()
	save_game()

func repay_loan(index: int):
	if index < 0 or index >= active_loans.size():
		return false

	var loan = active_loans[index]
	var remaining_total = int(loan.amount * (1.0 + loan.interest_rate) * (loan.remaining_installments / 10.0))

	if money >= remaining_total:
		money -= remaining_total
		active_loans.remove_at(index)
		stats_changed.emit()
		save_game()
		return true
	return false

func repair_truck(truck_id: String):
	if not owned_trucks.has(truck_id):
		return false

	var condition = owned_trucks[truck_id].condition
	var repair_cost = int((100.0 - condition) * 50) # Rs 50 per 1% damage

	if money >= repair_cost:
		money -= repair_cost
		owned_trucks[truck_id].condition = 100.0
		stats_changed.emit()
		save_game()
		return true
	return false

func refill_fuel_cost(amount: float):
	var city_mult = cities[current_city].fuel_mult
	var total_cost = int(amount * base_fuel_price * city_mult)

	if money >= total_cost:
		money -= total_cost
		stats_changed.emit()
		save_game()
		return true
	return false

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"money": money,
			"xp": xp,
			"level": level,
			"fuel": fuel,
			"current_city": current_city,
			"unlocked_cities": unlocked_cities,
			"owned_trucks": owned_trucks,
			"selected_truck": selected_truck,
			"hired_drivers": hired_drivers,
			"driver_pool": driver_pool,
			"company_reputation": company_reputation,
			"daily_profit_history": daily_profit_history,
			"active_loans": active_loans,
			"base_fuel_price": base_fuel_price,
			"daily_expenses_base": daily_expenses_base,
			"active_economic_event": active_economic_event
		}
		file.store_var(data)
		file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var data = file.get_var()
		if data:
			money = data.get("money", 1000)
			xp = data.get("xp", 0)
			level = data.get("level", 1)
			fuel = data.get("fuel", 100.0)
			current_city = data.get("current_city", "Lahore")
			unlocked_cities = data.get("unlocked_cities", ["Lahore"])
			owned_trucks = data.get("owned_trucks", {
				"bedford_rocket": {"speed": 0, "fuel": 0, "cargo": 0, "durability": 0, "condition": 100.0}
			})

			# Ensure all owned trucks have condition
			for t_id in owned_trucks:
				if not owned_trucks[t_id].has("condition"):
					owned_trucks[t_id]["condition"] = 100.0

			selected_truck = data.get("selected_truck", "bedford_rocket")
			hired_drivers = data.get("hired_drivers", {})
			driver_pool = data.get("driver_pool", [])
			company_reputation = data.get("company_reputation", 50)
			daily_profit_history = data.get("daily_profit_history", [])
			active_loans = data.get("active_loans", [])
			base_fuel_price = data.get("base_fuel_price", 150.0)
			daily_expenses_base = data.get("daily_expenses_base", 200)
			active_economic_event = data.get("active_economic_event", {"name": "Stable Economy", "reward_mult": 1.0, "fuel_price_mult": 1.0})

			_unlock_cities_for_level()
		file.close()
		stats_changed.emit()
