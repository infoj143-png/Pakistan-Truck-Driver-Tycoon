extends Area2D

enum ZoneType { PICKUP, DELIVERY }
@export var zone_type: ZoneType = ZoneType.PICKUP
@export var reward_money: int = 500
@export var reward_xp: int = 50

signal truck_entered_zone(type)

func _ready():
	add_to_group("zones")

func _on_body_entered(body):
	if body is Truck:
		truck_entered_zone.emit(zone_type)
		if zone_type == ZoneType.PICKUP:
			if not body.cargo_loaded:
				body.cargo_loaded = true
				print("Cargo Picked Up!")
		elif zone_type == ZoneType.DELIVERY:
			if body.cargo_loaded:
				body.cargo_loaded = false
				print("Cargo Delivered!")

				var truck_stats = GameManager.get_truck_stats(GameManager.selected_truck)
				var cargo_mult = truck_stats["cargo"] if truck_stats else 1.0

				var city_data = GameManager.cities[GameManager.current_city]
				var final_reward_money = int(reward_money * city_data["reward_mult"] * cargo_mult)
				var final_reward_xp = int(reward_xp * city_data["reward_mult"] * cargo_mult)
				GameManager.complete_mission(final_reward_money, final_reward_xp)
