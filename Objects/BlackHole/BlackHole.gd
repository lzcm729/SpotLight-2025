extends Node2D
class_name BlackHole


@export var mass : float = 1.0e4  # 黑洞质量


# 吞噬物体
func _on_吞噬范围_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		# 1) 停止运动，防止物理引擎继续推挤
		body._is_eaten = true
		# 2) 延迟释放，避免在物理回调中删除节点导致抖动  
		# body.call_deferred("queue_free")
		body.Destroy()


# 返回黑洞的吸引半径
func GetAttractionRadius() -> float:
	return $"引力范围/CollisionShape2D".shape.radius


func Strengthen() -> void:
	mass *= 10
	var floating_objects = get_tree().get_nodes_in_group("漂浮物") as Array[RigidBody2D]
	for obj in floating_objects:
		if obj is Pickable:
			obj.tangential_speed *= 10.0  # 增加切向速度
