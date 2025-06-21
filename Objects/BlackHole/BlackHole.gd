extends Node2D
class_name BlackHole


@export var mass : float = 1.0e4  # 黑洞质量


# 吞噬物体
func _on_吞噬范围_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		# 1) 停止运动，防止物理引擎继续推挤
		body._is_eaten = true
		# 2) 延迟释放，避免在物理回调中删除节点导致抖动  
		body.call_deferred("queue_free")


# 返回黑洞的吸引半径
func GetAttractionRadius() -> float:
	return $"引力范围/CollisionShape2D".shape.radius
