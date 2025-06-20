extends RigidBody2D
class_name SpaceShip

@export var tangential_speed: float = 100 # 切向速度
@export var radial_speed: float = -100    # 径向“下落”速度
var black_hole: BlackHole


func _ready() -> void:
	pass
		

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
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
