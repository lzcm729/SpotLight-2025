extends Node2D

@export var black_hole : BlackHole
@export var angular_speed : float = 1.0    # 单位：弧度/秒
@export var gravitational_constant : float = 100000  # 万有引力常数

@onready var floating_objects = get_tree().get_nodes_in_group("漂浮物") as Array[RigidBody2D]

func _ready() -> void:
	for obj in floating_objects:
		if obj is RigidBody2D:
			obj.black_hole = black_hole  # 设置黑洞引用
