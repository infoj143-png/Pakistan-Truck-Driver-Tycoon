extends Area2D

enum ZoneType { PICKUP, DELIVERY }
@export var zone_type: ZoneType = ZoneType.PICKUP
@export var reward_money: int = 500
@export var reward_xp: int = 50

signal truck_entered_zone(type)

func _on_body_entered(body):
	if body.name == "Truck":
		truck_entered_zone.emit(zone_type)
		if zone_type == ZoneType.PICKUP:
			if not body.cargo_loaded:
				body.cargo_loaded = true
				print("Cargo Picked Up!")
		elif zone_type == ZoneType.DELIVERY:
			if body.cargo_loaded:
				body.cargo_loaded = false
				print("Cargo Delivered!")
				GameManager.complete_mission(reward_money, reward_xp)
