extends Pickable
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _be_picked_up(space_ship:SpaceShip) -> void:
	space_ship.modify_health(-10)
	audio_stream_player.play()
	super(space_ship)
