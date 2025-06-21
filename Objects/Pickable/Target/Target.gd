extends Pickable


func _be_picked_up(space_ship:SpaceShip) -> void:
	queue_free()
