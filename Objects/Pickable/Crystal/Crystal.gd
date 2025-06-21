extends Pickable

func _be_picked_up(space_ship:SpaceShip) -> void:
	space_ship.modify_energy(10)
	queue_free()
