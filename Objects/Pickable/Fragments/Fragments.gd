extends Pickable


func BePickUp(space_ship:SpaceShip) -> void:
	# 物体被拾取时调用
	# 可以在这里添加拾取逻辑
	queue_free()  # 直接销毁物体
