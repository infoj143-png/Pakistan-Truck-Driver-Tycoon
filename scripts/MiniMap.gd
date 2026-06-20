extends Control

@onready var viewport = %SubViewport
@onready var map_camera = %MapCamera
@onready var distance_label = %DistanceLabel
@onready var city_label = %CityLabel
@onready var objective_label = %ObjectiveLabel
@onready var arrow = %DirectionArrow

var truck: CharacterBody2D
var pickup_zone: Area2D
var delivery_zone: Area2D

func _ready():
	truck = get_tree().get_first_node_in_group("truck")

	# Try to find zones in the scene
	var zones = get_tree().get_nodes_in_group("zones")
	for zone in zones:
		if zone.zone_type == zone.ZoneType.PICKUP:
			pickup_zone = zone
		elif zone.zone_type == zone.ZoneType.DELIVERY:
			delivery_zone = zone

	# Fallback search if group isn't set
	if not pickup_zone:
		pickup_zone = get_tree().root.find_child("PickupZone", true, false)
	if not delivery_zone:
		delivery_zone = get_tree().root.find_child("DeliveryZone", true, false)

	city_label.text = "Route: " + GameManager.current_city

	# Set viewport world to match main world so it sees the same nodes
	viewport.world_2d = get_tree().root.get_viewport().world_2d

func _process(_delta):
	if not truck:
		truck = get_tree().get_first_node_in_group("truck")
		return

	# Update camera position
	map_camera.position = truck.position

	# Determine current objective
	var target_pos: Vector2
	var objective_text: String

	if not GameManager.cargo_loaded:
		target_pos = pickup_zone.position if pickup_zone else truck.position
		objective_text = "Go to Pickup Point"
	else:
		target_pos = delivery_zone.position if delivery_zone else truck.position
		objective_text = "Go to Delivery Point"

	objective_label.text = objective_text

	# Update distance
	var dist = truck.position.distance_to(target_pos)
	distance_label.text = "Distance: %.0f m" % (dist / 10.0) # Arbitrary scaling

	# Update arrow
	var angle = truck.position.angle_to_point(target_pos)
	arrow.rotation = angle + PI/2 # Adjust based on arrow texture orientation

	if not GameManager.cargo_loaded:
		arrow.modulate = Color.GREEN
	else:
		arrow.modulate = Color.RED
