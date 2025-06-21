@tool
extends Line2D

@export var segments: int = 32 : set = set_segments
@export var radius: float = 100.0 : set = set_radius

func _ready():
	if Engine.is_editor_hint():
		_update_circle()

func set_segments(v):
	segments = v
	if Engine.is_editor_hint():
		_update_circle()

func set_radius(v):
	radius = v
	if Engine.is_editor_hint():
		_update_circle()

func _update_circle():
	var pts = []
	for i in range(segments + 1):
		var a = float(i) / segments * TAU
		pts.append(Vector2(cos(a), sin(a)) * radius)
	points = pts
