extends Area2D

enum ZoneType { PICKUP, DELIVERY }
@export var type: ZoneType = ZoneType.PICKUP

signal zone_activated(type)

func _on_body_entered(body):
	if body.name == "Truck":
		zone_activated.emit(type)
