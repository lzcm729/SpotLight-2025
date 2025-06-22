extends Node2D

signal level_lost

@onready var black_hole = $Universe/BlackHole
@onready var space_ship = $Universe/SpaceShip


func _ready() -> void:
	black_hole.ship_gone.connect(_on_ship_gone)
	space_ship.health_depleted.connect(_on_ship_gone)
	
	
func _on_ship_gone() -> void:
	level_lost.emit()
