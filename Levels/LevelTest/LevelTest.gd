extends Node2D

@export var black_hole     : BlackHole
@export var angular_speed  : float = 1.0       # 单位：弧度/秒
@export var gravitational_constant : float = 100000  # 万有引力常数

# 新增：要生成的 Fragment 场景、间隔时间、生成半径
@export var fragment_scene : PackedScene
@export var spawn_interval : float = 2.0       # 间隔秒数
@export var spawn_radius   : float = 400.0     # 距离黑洞中心的半径

@onready var floating_objects = get_tree().get_nodes_in_group("漂浮物") as Array[RigidBody2D]
