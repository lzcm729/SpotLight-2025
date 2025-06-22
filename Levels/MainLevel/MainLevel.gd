extends Node2D

signal level_lost
signal level_won

var boomed = false  # 是否已经生成过炸弹

@onready var black_hole = $Universe/BlackHole
@onready var space_ship = $Universe/SpaceShip
@onready var daughter_manager: Node = $DaughterManager
@onready var game_goal: GameGoal = $HUD/GameGoal

func _ready() -> void:
	black_hole.ship_gone.connect(_on_ship_gone)
	black_hole.strength_changed.connect(_on_black_hole_strength_changed)
	space_ship.health_depleted.connect(_on_ship_gone)
	
	
func _on_ship_gone() -> void:
	level_lost.emit()

func _on_black_hole_strength_changed() -> void:
	# 黑洞变强时，生成第二颗炸弹
	if not boomed:
		SpawnSecondBomb()
		boomed = true  # 标记已经生成过炸弹
	else:
		level_won.emit()  # 如果已经生成过炸弹，则认为关卡胜利

func RestartLevel() -> void:
	# 重置飞船状态
	space_ship.set_health(space_ship.max_health)
	space_ship.set_energy(space_ship.max_energy)
	space_ship.position = Vector2(100, 400)  # 重置位置
	space_ship.rotation = 0.0  # 重置旋转角度
	space_ship.freeze = false  # 解除冻结状态
	space_ship.visible = true  # 重新显示飞船


# 生成第二颗炸弹
func SpawnSecondBomb() -> void:
	var second_bomb = load("res://Objects/Pickable/Boom/Boom.tscn").instantiate()
	second_bomb.freeze = true
	# 在黑洞边缘随机一个位置
	var pos = black_hole.position + Vector2(randf_range(-black_hole.GetAttractionRadius(), black_hole.GetAttractionRadius()), randf_range(-black_hole.GetAttractionRadius(), black_hole.GetAttractionRadius()))
	second_bomb.position = pos
	game_goal.show_game_goal_2()
	second_bomb.set_deferred("freeze", false)  # 解冻炸弹，使其开始运动
	$Universe.add_child(second_bomb)  # 添加到场景中
