extends Pickable
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _be_picked_up(space_ship:SpaceShip) -> void:
	space_ship.gain_experience(50)
	audio_stream_player.play()
	super(space_ship)
