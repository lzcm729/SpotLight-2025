extends Node2D

signal level_lost

@onready var black_hole = $Universe/BlackHole

func _ready() -> void:
	black_hole.ship_gone.connect(_on_ship_gone)
	
	
func _on_ship_gone() -> void:
	level_lost.emit()
