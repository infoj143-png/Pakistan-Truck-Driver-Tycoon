extends Node

const SAVE_PATH = "user://save_game.dat"

# Player Stats
var money: int = 1000
var xp: int = 0
var level: int = 1
var fuel: float = 100.0
var cargo_loaded: bool = false
var first_time_menu: bool = true

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

# Rewards and Achievements State
var last_login_date: String = ""
var consecutive_logins: int = 0
var reward_claimed_today: bool = false
var total_deliveries: int = 0
var unlocked_achievements: Array = []
var unlocked_skins: Array = ["default"]
var selected_skin: String = "default"
var achievement_progress: Dictionary = {} # id -> current_value

# Cached data for WeatherManager in case of initialization order issues
var _loaded_weather_state = null

signal stats_changed
signal mission_completed(reward_money, reward_xp)
signal daily_report_generated(report_data)
signal achievement_unlocked(achievement_id)
signal skin_unlocked(skin_id)
signal skin_changed(skin_id)

const DAILY_REWARDS = [
	{"day": 1, "type": "money", "amount": 500},
	{"day": 2, "type": "xp", "amount": 100},
	{"day": 3, "type": "money", "amount": 1000},
	{"day": 4, "type": "xp", "amount": 250},
	{"day": 5, "type": "skin", "id": "pak_green", "name": "Patriotic Green"},
	{"day": 6, "type": "money", "amount": 2500},
	{"day": 7, "type": "skin", "id": "truck_art_royal", "name": "Royal Truck Art"}
]

const ACHIEVEMENTS = {
	"level_5": {"name": "Junior Driver", "description": "Reach Level 5", "type": "level", "goal": 5, "reward_money": 1000},
	"level_10": {"name": "Senior Driver", "description": "Reach Level 10", "type": "level", "goal": 10, "reward_money": 5000},
	"deliveries_10": {"name": "Getting Started", "description": "Complete 10 deliveries", "type": "deliveries", "goal": 10, "reward_xp": 200},
	"deliveries_50": {"name": "Pro Deliverer", "description": "Complete 50 deliveries", "type": "deliveries", "goal": 50, "reward_money": 10000, "reward_skin": "golden_eagle"},
	"fleet_3": {"name": "Small Business", "description": "Hire 3 drivers", "type": "fleet", "goal": 3, "reward_money": 2000},
	"fleet_10": {"name": "Logistics Giant", "description": "Hire 10 drivers", "type": "fleet", "goal": 10, "reward_money": 20000, "reward_skin": "platinum_fleet"}
}

const SKINS = {
	"default": {"name": "Standard", "color": Color.WHITE},
	"pak_green": {"name": "Patriotic Green", "color": Color.DARK_GREEN},
	"truck_art_royal": {"name": "Royal Truck Art", "color": Color.INDIAN_RED},
	"golden_eagle": {"name": "Golden Eagle", "color": Color.GOLD},
	"platinum_fleet": {"name": "Platinum Fleet", "color": Color.SLATE_GRAY}
}

# UI Styling Constants
const TRUCK_ART_COLORS = {
	"red": Color("#e63946"),
	"yellow": Color("#ffb703"),
	"blue": Color("#1d3557"),
	"green": Color("#06d6a0"),
	"orange": Color("#fb8500"),
	"pink": Color("#ff006e"),
	"white": Color.WHITE,
	"dark_bg": Color("#121212")
}

func goto_scene(path: String):
	print("[GameManager] Navigating to scene: ", path)
	# Save game before transitioning to ensure all state (like fuel/condition) is persisted
	save_game()

	var loading_screen = load("res://ui/Loading.tscn").instantiate()
	# Set mouse filter to ignore so it doesn't block inputs during transition
	loading_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_tree().root.add_child(loading_screen)

	# Wait a bit to show the loading screen
	await get_tree().create_timer(1.0).timeout

	var result = get_tree().change_scene_to_file(path)
	if result != OK:
		print("[GameManager] Error changing scene: ", result)

	# Wait for the next scene to be ready before removing loading screen
	await get_tree().process_frame
	loading_screen.queue_free()

func get_truck_art_stylebox(bg_color: Color = TRUCK_ART_COLORS["blue"], border_color: Color = TRUCK_ART_COLORS["yellow"], border_width: int = 4):
	var sb = StyleBoxFlat.new()
	sb.bg_color = bg_color
	sb.border_width_left = border_width
	sb.border_width_top = border_width
	sb.border_width_right = border_width
	sb.border_width_bottom = border_width
	sb.border_color = border_color
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_right = 10
	sb.corner_radius_bottom_left = 10
	sb.expand_margin_left = 2
	sb.expand_margin_top = 2
	sb.expand_margin_right = 2
	sb.expand_margin_bottom = 2
	return sb

func _ready():
	load_game()
	check_daily_login()
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
	total_deliveries += 1
	update_achievement_progress("deliveries", 1, false)
	mission_completed.emit(reward_money, reward_xp)

func buy_truck(truck_id: String):
	if not TRUCK_DATA.has(truck_id):
		return false

	var price = TRUCK_DATA[truck_id]["price"]
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

	var base_cost = TRUCK_DATA[truck_id]["upgrade_costs"][stat_id]
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

	var base_stats = TRUCK_DATA[truck_id]["base_stats"]
	var stats = base_stats.duplicate()

	if owned_trucks.has(truck_id):
		var upgrades = owned_trucks[truck_id]
		# Each upgrade level adds 10% to the base stat
		stats["speed"] += base_stats["speed"] * (upgrades["speed"] * 0.1)
		stats["fuel"] += base_stats["fuel"] * (upgrades["fuel"] * 0.1)
		stats["cargo"] += base_stats["cargo"] * (upgrades["cargo"] * 0.1)
		stats["durability"] += base_stats["durability"] * (upgrades["durability"] * 0.1)

	return stats

func _check_level_up():
	var xp_needed = level * 100 # Simple level up logic
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = level * 100
		print("Level Up! Current Level: ", level)
		_unlock_cities_for_level()
		update_achievement_progress("level", level, true)

func _unlock_cities_for_level():
	for city_name in cities:
		if cities[city_name]["unlock_level"] <= level:
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
		hired_drivers[driver["id"]] = driver
		driver_pool.remove_at(pool_index)

		# Refill pool if empty
		if driver_pool.is_empty():
			generate_driver_pool()

		update_achievement_progress("fleet", hired_drivers.size(), true)

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
		if hired_drivers[id]["assigned_truck"] == truck_id:
			hired_drivers[id]["assigned_truck"] = ""

	hired_drivers[driver_id]["assigned_truck"] = truck_id
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
		total_salaries += driver["salary"]

		if driver["assigned_truck"] != "" and owned_trucks.has(driver["assigned_truck"]):
			var truck_stats = get_truck_stats(driver["assigned_truck"])
			var truck_data = owned_trucks[driver["assigned_truck"]]

			if truck_stats:
				# Maintenance cost based on condition
				var maintenance = int((100.0 - truck_data["condition"]) * 2)
				total_maintenance += maintenance

				var income = int(BASE_PASSIVE_INCOME * driver["skills"]["efficiency"] * truck_stats["cargo"] * event_reward_mult)
				total_income += income

				# Reliability check - random chance to lose reputation or income if unreliable
				if randf() > driver["skills"]["reliability"]:
					daily_rep_change -= 1
				else:
					daily_rep_change += 1
		else:
			# Unassigned drivers still take salary but don't earn much, and reputation might drop
			daily_rep_change -= 1

	# Loan Repayments
	var remaining_loans = []
	for loan in active_loans:
		var installment = int((loan["amount"] * (1.0 + loan["interest_rate"])) / 10.0) # 10 installments
		total_loan_repayments += installment
		loan["remaining_installments"] -= 1
		if loan["remaining_installments"] > 0:
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
		"event": active_economic_event["name"]
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
	base_fuel_price = 150.0 * active_economic_event["fuel_price_mult"]
	print("New Economic Event: ", active_economic_event["name"])

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
	var remaining_total = int(loan["amount"] * (1.0 + loan["interest_rate"]) * (loan["remaining_installments"] / 10.0))

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

	var condition = owned_trucks[truck_id]["condition"]
	var repair_cost = int((100.0 - condition) * 50) # Rs 50 per 1% damage

	if money >= repair_cost:
		money -= repair_cost
		owned_trucks[truck_id]["condition"] = 100.0
		stats_changed.emit()
		save_game()
		return true
	return false

func refill_fuel_cost(amount: float):
	var city_mult = cities[current_city]["fuel_mult"]
	var total_cost = int(amount * base_fuel_price * city_mult)

	if money >= total_cost:
		money -= total_cost
		stats_changed.emit()
		save_game()
		return true
	return false

# Reward and Achievement Logic
func check_daily_login():
	var now_dict = Time.get_date_dict_from_system()
	var today_str = "%d-%d-%d" % [now_dict["year"], now_dict["month"], now_dict["day"]]

	# Create a dictionary for today at midnight to get a clean unix timestamp for comparison
	var today_midnight = {"year": now_dict["year"], "month": now_dict["month"], "day": now_dict["day"], "hour": 0, "minute": 0, "second": 0}
	var today_unix = Time.get_unix_time_from_datetime_dict(today_midnight)

	if last_login_date == "":
		last_login_date = today_str
		consecutive_logins = 1
		reward_claimed_today = false
	elif last_login_date != today_str:
		var last_parts = last_login_date.split("-")
		if last_parts.size() == 3:
			var last_midnight = {"year": int(last_parts[0]), "month": int(last_parts[1]), "day": int(last_parts[2]), "hour": 0, "minute": 0, "second": 0}
			var last_unix = Time.get_unix_time_from_datetime_dict(last_midnight)

			var seconds_diff = today_unix - last_unix
			# 86400 seconds in a day.
			var is_yesterday = seconds_diff == 86400

			if is_yesterday:
				consecutive_logins += 1
				if consecutive_logins > 7:
					consecutive_logins = 1
			elif seconds_diff > 86400:
				consecutive_logins = 1
			# if seconds_diff < 0, they set their clock back.
			# We don't advance consecutive_logins to prevent exploits.
		else:
			consecutive_logins = 1

		last_login_date = today_str
		reward_claimed_today = false

	save_game()

func claim_daily_reward():
	if reward_claimed_today:
		return false

	var reward = DAILY_REWARDS[consecutive_logins - 1]
	match reward["type"]:
		"money":
			add_money(reward["amount"])
		"xp":
			add_xp(reward["amount"])
		"skin":
			unlock_skin(reward["id"])

	reward_claimed_today = true
	save_game()
	return true

func unlock_skin(skin_id: String):
	if not unlocked_skins.has(skin_id):
		unlocked_skins.append(skin_id)
		skin_unlocked.emit(skin_id)
		save_game()

func set_selected_skin(skin_id: String):
	if unlocked_skins.has(skin_id):
		selected_skin = skin_id
		skin_changed.emit(skin_id)
		save_game()
		return true
	return false

func update_achievement_progress(type: String, amount: int, is_absolute: bool = false):
	for id in ACHIEVEMENTS:
		var ach = ACHIEVEMENTS[id]
		if ach["type"] == type:
			var current = achievement_progress.get(id, 0)
			if current < ach["goal"]:
				if is_absolute:
					current = max(current, amount)
				else:
					current += amount
				achievement_progress[id] = current

				if current >= ach["goal"] and not unlocked_achievements.has(id):
					unlock_achievement(id)

	save_game()

func unlock_achievement(id: String):
	if not unlocked_achievements.has(id):
		unlocked_achievements.append(id)
		var ach = ACHIEVEMENTS[id]

		if ach.has("reward_money"):
			add_money(ach["reward_money"])
		if ach.has("reward_xp"):
			add_xp(ach["reward_xp"])
		if ach.has("reward_skin"):
			unlock_skin(ach["reward_skin"])

		achievement_unlocked.emit(id)
		save_game()

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var weather_node = get_node_or_null("/root/WeatherManager")
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
			"active_economic_event": active_economic_event,
			"last_login_date": last_login_date,
			"consecutive_logins": consecutive_logins,
			"reward_claimed_today": reward_claimed_today,
			"total_deliveries": total_deliveries,
			"unlocked_achievements": unlocked_achievements,
			"unlocked_skins": unlocked_skins,
			"selected_skin": selected_skin,
			"achievement_progress": achievement_progress,
			"cargo_loaded": cargo_loaded,
			"current_weather": weather_node.current_weather if weather_node else (_loaded_weather_state["weather"] if _loaded_weather_state else 0),
			"current_time": weather_node.current_time if weather_node else (_loaded_weather_state["time"] if _loaded_weather_state else 8.0)
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
			last_login_date = data.get("last_login_date", "")
			consecutive_logins = data.get("consecutive_logins", 0)
			reward_claimed_today = data.get("reward_claimed_today", false)
			total_deliveries = data.get("total_deliveries", 0)
			unlocked_achievements = data.get("unlocked_achievements", [])
			unlocked_skins = data.get("unlocked_skins", ["default"])
			selected_skin = data.get("selected_skin", "default")
			achievement_progress = data.get("achievement_progress", {})
			cargo_loaded = data.get("cargo_loaded", false)

			_loaded_weather_state = {
				"weather": data.get("current_weather", 0),
				"time": data.get("current_time", 8.0)
			}

			var weather_node = get_node_or_null("/root/WeatherManager")
			if weather_node:
				weather_node.current_weather = _loaded_weather_state["weather"]
				weather_node.current_time = _loaded_weather_state["time"]

			_unlock_cities_for_level()
		file.close()
		stats_changed.emit()
