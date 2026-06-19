extends Node

const SAVE_PATH = "user://save_game.dat"

# Player Stats
var money: int = 1000
var xp: int = 0
var level: int = 1
var fuel: float = 100.0

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
	"bedford_rocket": {"speed": 0, "fuel": 0, "cargo": 0, "durability": 0}
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

func _ready():
	load_game()

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
		owned_trucks[truck_id] = {"speed": 0, "fuel": 0, "cargo": 0, "durability": 0}
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
			"selected_truck": selected_truck
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
				"bedford_rocket": {"speed": 0, "fuel": 0, "cargo": 0, "durability": 0}
			})
			selected_truck = data.get("selected_truck", "bedford_rocket")
			_unlock_cities_for_level()
		file.close()
		stats_changed.emit()
