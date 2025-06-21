extends Pickable


func _be_picked_up(space_ship:SpaceShip) -> void:
	space_ship.modify_health(10)
	super(space_ship)
