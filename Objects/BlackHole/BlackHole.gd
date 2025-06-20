extends Node2D
class_name BlackHole


@export var attraction_strength : float = 1000.0
@export var mass : float = 1.0e4  # 黑洞质量


func _on_吞噬范围_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		body.queue_free()  # 吞噬物体
