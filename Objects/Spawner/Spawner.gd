extends Marker2D

@export var spawn_class : PackedScene
@export var spawn_interval : float = 2.0       # 间隔秒数
@export var spawn_radius   : float = 400.0     # 距离黑洞中心的半径

var _time_accumulator : float = 0.0
var black_hole: BlackHole

func _ready() -> void:
	black_hole = get_tree().get_first_node_in_group("BlackHole")

func _process(delta: float) -> void:
	_time_accumulator += delta
	if _time_accumulator >= spawn_interval:
		_time_accumulator -= spawn_interval
		_spawn_fragment()

func _spawn_fragment() -> void:
	if spawn_class == null:
		return
	# 实例化并随机选角度放置在黑洞周围
	var instance = spawn_class.instantiate() as Pickable
	var angle = randf() * TAU
	instance.global_position = black_hole.global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
	# 加到当前场景，并加入漂浮物组
	get_tree().current_scene.add_child(instance)
