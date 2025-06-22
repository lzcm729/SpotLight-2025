extends Pickable
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _be_picked_up(space_ship:SpaceShip) -> void:
	audio_stream_player.play()
	space_ship.modify_energy(10)
	super(space_ship)
