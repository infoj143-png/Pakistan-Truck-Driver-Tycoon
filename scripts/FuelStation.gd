extends Area2D

signal truck_near_fuel_station(is_near)

func _ready():
	add_to_group("fuel_stations")

func _on_body_entered(body):
	if body is Truck:
		truck_near_fuel_station.emit(true)
		if body.has_method("set_near_fuel_station"):
			body.set_near_fuel_station(true)

func _on_body_exited(body):
	if body is Truck:
		truck_near_fuel_station.emit(false)
		if body.has_method("set_near_fuel_station"):
			body.set_near_fuel_station(false)
