extends Node2D

@export var black_hole : BlackHole
@export var angular_speed : float = 1.0    # 单位：弧度/秒
@export var gravitational_constant : float = 1000  # 万有引力常数

# 距离乘数
@export var distance_multiplier : float = 0.5

@onready var floating_objects = get_tree().get_nodes_in_group("漂浮物") as Array[RigidBody2D]

func _ready() -> void:
	for obj in floating_objects:
		var offset : Vector2 = obj.global_position - black_hole.global_position
		var radius = offset.length()
		if radius > 0:
			# 计算垂直于半径方向的切向单位向量（逆时针方向）
			var tangent = Vector2(-offset.y, offset.x).normalized()
			# 设置初始切向速度，确保匀速圆周运动所需
			var speed = angular_speed * radius
			obj.linear_velocity = tangent * speed


func _physics_process(_delta: float) -> void:
	for obj in floating_objects:
		if obj:
			var offset : Vector2 = obj.global_position - black_hole.global_position
			var distance = offset.length()
			if distance > 0:
				# 计算当前所需的向心力
				# 计算万有引力大小（F = G * m1 * m2 / r^2）
				var force_magnitude = gravitational_constant * obj.mass * black_hole.mass / pow(_modify_distance(distance), 2)
				var force_direction = -offset.normalized()   # 指向黑洞中心
				var force = force_direction * force_magnitude
				obj.apply_central_force(force)


# 调整距离对万有引力的影响
func _modify_distance(distance: float) -> float:
	# 使用距离乘数来调整距离
	return distance * distance_multiplier