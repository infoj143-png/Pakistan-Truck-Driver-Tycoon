extends Node

const SAVE_PATH = "user://save_game.dat"

# Player Stats
var money: int = 1000
var xp: int = 0
var level: int = 1
var fuel: float = 100.0

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
			"unlocked_cities": unlocked_cities
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
			_unlock_cities_for_level()
		file.close()
		stats_changed.emit()
