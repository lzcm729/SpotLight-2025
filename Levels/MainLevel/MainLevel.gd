extends Node2D

signal level_lost

@onready var black_hole = $Universe/BlackHole
@onready var space_ship = $Universe/SpaceShip


func _ready() -> void:
	black_hole.ship_gone.connect(_on_ship_gone)
	space_ship.health_depleted.connect(_on_ship_gone)
	
	
func _on_ship_gone() -> void:
	level_lost.emit()


func RestartLevel() -> void:
	# 重置飞船状态
	space_ship.set_health(space_ship.max_health)
	space_ship.set_energy(space_ship.max_energy)
	space_ship.position = Vector2(100, 400)  # 重置位置
	space_ship.rotation = 0.0  # 重置旋转角度
	space_ship.freeze = false  # 解除冻结状态
	space_ship.visible = true  # 重新显示飞船
