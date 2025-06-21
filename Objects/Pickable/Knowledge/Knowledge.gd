extends Pickable


func _be_picked_up(space_ship:SpaceShip) -> void:
	space_ship.gain_experience(50)
	super(space_ship)
