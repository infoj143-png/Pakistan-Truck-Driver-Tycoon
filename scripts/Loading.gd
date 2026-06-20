extends Control

@onready var truck_icon = $VBoxContainer/TruckIcon

func _ready():
	truck_icon.texture = load("res://icon.svg")
	# Add some color to the icon
	truck_icon.self_modulate = GameManager.TRUCK_ART_COLORS.red

func _process(delta):
	truck_icon.rotation += delta * 5.0
