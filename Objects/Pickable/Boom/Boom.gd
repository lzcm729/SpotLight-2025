extends Pickable

func _destroy():
	black_hole.Strengthen()
	queue_free()


func _be_picked_up(_space_ship:SpaceShip) -> void:
	return
