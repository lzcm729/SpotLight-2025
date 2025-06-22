extends Pickable
class_name Boom

func _destroy():
	queue_free()


func _be_picked_up(_space_ship:SpaceShip) -> void:
	return
