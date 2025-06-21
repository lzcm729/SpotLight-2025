extends Node2D

@export var black_hole     : BlackHole
@export var angular_speed  : float = 1.0       # 单位：弧度/秒
@export var gravitational_constant : float = 100000  # 万有引力常数


# 按下空格后开始测试
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_start_test()


func _start_test() -> void:
	var floating_objects = get_tree().get_nodes_in_group("漂浮物") as Array[RigidBody2D]
	for obj in floating_objects:
		if obj is Pickable:
			obj.tangential_speed *= 10.0  # 增加切向速度
