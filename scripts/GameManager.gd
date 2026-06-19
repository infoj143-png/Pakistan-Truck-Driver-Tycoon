extends Node

const SAVE_PATH = "user://save_game.dat"

# Player Stats
var money: int = 1000
var xp: int = 0
var level: int = 1
var fuel: float = 100.0

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

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"money": money,
			"xp": xp,
			"level": level,
			"fuel": fuel
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
		file.close()
		stats_changed.emit()
