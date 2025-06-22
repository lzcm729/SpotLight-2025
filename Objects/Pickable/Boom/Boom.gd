extends Pickable
class_name Boom
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _destroy():
	queue_free()


func _be_picked_up(_space_ship:SpaceShip) -> void:
	
	return
