extends RigidBody2D
class_name Pickable

signal pick(item_id: int)

var black_hole: BlackHole
var _is_eaten: bool = false  # 是否被黑洞吞噬

@export var tangential_speed: float = 100 # 切向速度
@export var radial_speed: float = -100    # 径向"下落"速度
@export var item_id: int = 0

@onready var pick_id: Label = $pick_id

func _ready() -> void:
	black_hole = get_tree().get_first_node_in_group("BlackHole")
	pick_id.text = str(item_id)
		

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _is_eaten:
		# 如果物体已经被黑洞吞噬，则不再施加任何力
		return
	var offset = state.transform.origin - black_hole.position
	if offset.length() <= 0: return
	# 1) 计算径向和切向单位向量
	var radial = offset.normalized()
	var tangential = radial.rotated(PI / 2)  # 切向向量是径向向量逆时针旋转90度
	# 2) 合成螺旋速度
	state.linear_velocity = tangential * tangential_speed + radial * _get_current_radial_speed()


func _get_current_radial_speed() -> float:
	# 返回当前的径向速度
	# 和黑洞距离有关
	var offset = position - black_hole.position
	var distance = offset.length()
	# 距离越近，径向速度越大
	var percentage = clamp(distance / black_hole.GetAttractionRadius(), 0.0, 1.0)
	# 计算径向速度
	return radial_speed * (1.0 - percentage)


func BePickUp(space_ship:SpaceShip) -> void:
	# 物体被拾取时调用
	_be_picked_up(space_ship)
	pick.emit(item_id)
	# 播放拾取动画,向上移动并慢慢消失
	var tween = create_tween()
	tween.set_parallel(true)  # 设置并行执行
	tween.tween_property(self, "position", self.position + Vector2.UP * 100, 1.0)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free).set_delay(1.0)


func _be_picked_up(space_ship:SpaceShip) -> void:
	return


func Destroy() -> void:
	if _is_eaten:
		# 移动到黑洞的中心，同时慢慢消失
		var tween = create_tween()
		tween.set_parallel(true)  # 设置并行执行
		tween.tween_property(self, "position", black_hole.position + Vector2.UP * 10, 1.0)
		tween.tween_property(self, "modulate:a", 0.0, 1.0)
		tween.tween_callback(queue_free).set_delay(1.0)
	else:
		_destroy()
		queue_free()
		



func _destroy() -> void:
	pass
