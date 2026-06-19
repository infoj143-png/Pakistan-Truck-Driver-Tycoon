extends Control

@onready var fuel_bar = $HUD/MarginContainer/VBoxContainer/FuelBar
@onready var cargo_status = $HUD/MarginContainer/VBoxContainer/CargoStatus
@onready var complete_popup = $HUD/MissionCompletePopup
@onready var game_over_popup = $HUD/GameOverPopup

@onready var pickup_zone = $SubViewportContainer/SubViewport/World/PickupZone
@onready var delivery_zone = $SubViewportContainer/SubViewport/World/DeliveryZone

var mission_finished: bool = false

func _ready():
	GameManager.fuel = 100.0
	GameManager.has_cargo = false

	pickup_zone.zone_activated.connect(_on_zone_activated)
	delivery_zone.zone_activated.connect(_on_zone_activated)

func _process(_delta):
	if mission_finished:
		return

	fuel_bar.value = GameManager.fuel
	cargo_status.text = "Cargo: " + ("Picked Up" if GameManager.has_cargo else "None")

	if GameManager.fuel <= 0:
		_show_game_over()

func _on_zone_activated(type):
	if mission_finished:
		return

	if type == 0: # PICKUP
		if not GameManager.has_cargo:
			GameManager.has_cargo = true
			print("Cargo Picked Up!")
	elif type == 1: # DELIVERY
		if GameManager.has_cargo:
			_complete_mission()

func _complete_mission():
	mission_finished = true
	GameManager.add_money(500)
	GameManager.add_xp(100)
	complete_popup.show()

func _show_game_over():
	mission_finished = true
	game_over_popup.show()

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")

func _on_retry_pressed():
	get_tree().reload_current_scene()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://ui/MainMenu.tscn")
