extends Node

# 全局存储女儿当前年龄
var global_daughter_age: int = 0
var time_speed: float = 1.0
@onready var age_pass: Timer = $AgePass

# 时间流逝相关变量
var time_elapsed: float = 0.0  # 当前周期内已经流逝的时间
var base_cycle_time: float = 10.0  # 基础周期时间（1倍速时的周期）
var current_cycle_time: float = 10.0  # 当前周期时间

# 年龄文本字典，索引直接对应年龄，每5岁存储2-3条文本内容
var age_texts: Dictionary = {
	0: [
		"0岁1",
		"0岁2",
		"0岁3"
	],
	5: [
		"5岁1",
		"5岁2",
		"5岁3"
	],
	10: [
		"10岁1",
		"10岁2",
		"10岁3"
	],
	15: [
		"15岁1",
		"15岁2",
		"15岁3"
	],
	20: [
		"20岁1",
		"20岁2",
		"20岁3"
	],
	25: [
		"25岁1",
		"25岁2",
		"25岁3"
	],
	30: [
		"30岁1",
		"30岁2",
		"30岁3"
	],
	35: [
		"35岁1",
		"35岁2",
		"35岁3"
	],
	40: [
		"40岁1",
		"40岁2",
		"40岁3"
	],
	45: [
		"45岁1",
		"45岁2",
		"45岁3"
	],
	50: [
		"50岁1",
		"50岁2",
		"50岁3"
	],
	55: [
		"55岁1",
		"55岁2",
		"55岁3"
	],
	60: [
		"60岁1",
		"60岁2",
		"60岁3"
	],
	65: [
		"65岁1",
		"65岁2",
		"65岁3"
	],
	70: [
		"70岁1",
		"70岁2",
		"70岁3"
	],
	75: [
		"75岁1",
		"75岁2",
		"75岁3"
	],
	80: [
		"80岁1",
		"80岁2",
		"80岁3"
	],
	85: [
		"85岁1",
		"85岁2",
		"85岁3"
	],
	90: [
		"90岁1",
		"90岁2",
		"90岁3"
	],
	95: [
		"95岁1",
		"95岁2",
		"95岁3"
	],
	100: [
		"100岁1",
		"100岁2",
		"100岁3"
	]
}

# 信号：每当5岁时触发，发送该年龄的所有句子
signal age_five_reached(age: int, sentences: Array[String])
# 信号：每当年龄变化时触发
signal age_changed(new_age: int, old_age: int)

func _ready():
	# 初始化女儿年龄
	global_daughter_age = 0
	
	# 初始化Timer系统
	initialize_timer_system()

# 初始化Timer系统
func initialize_timer_system():
	current_cycle_time = base_cycle_time / time_speed
	age_pass.wait_time = current_cycle_time
	age_pass.timeout.connect(_on_age_pass_timeout)
	age_pass.start()

# 获取真实的剩余时间（考虑已流逝时间）
func get_real_time_left() -> float:
	return age_pass.time_left

# 获取真实的周期时间
func get_real_cycle_time() -> float:
	return current_cycle_time

# 获取真实的已流逝时间
func get_real_elapsed_time() -> float:
	return time_elapsed

# 获取真实的进度比例（0.0 - 1.0）
func get_real_progress() -> float:
	# 如果Timer刚刚重置，直接使用Timer的进度
	if time_elapsed == 0.0:
		return (current_cycle_time - age_pass.time_left) / current_cycle_time
	else:
		# 如果正在调整速度，考虑已流逝时间
		var total_elapsed = time_elapsed + (current_cycle_time - age_pass.time_left)
		return total_elapsed / current_cycle_time

# 获取真实的剩余时间比例（0.0 - 1.0）
func get_real_remaining_ratio() -> float:
	return 1.0 - get_real_progress()

# 调整时间流动速度
func set_time_speed(speed_multiplier: float):
	# speed_multiplier: 时间速度倍数
	# 1.0 = 正常速度（10秒/岁）
	# 2.0 = 2倍速（5秒/岁）
	# 0.5 = 0.5倍速（20秒/岁）
	# 0.1 = 0.1倍速（100秒/岁）
	
	var old_speed = time_speed
	time_speed = speed_multiplier
	
	# 计算当前已经流逝的时间
	var current_time_left = age_pass.time_left
	var old_cycle_time = current_cycle_time
	time_elapsed = old_cycle_time - current_time_left
	
	# 计算新的周期时间
	current_cycle_time = base_cycle_time / time_speed
	
	# 计算新的剩余时间，保持已流逝时间的比例
	var new_time_left = current_cycle_time - time_elapsed
	
	# 确保剩余时间不为负数
	if new_time_left <= 0:
		new_time_left = 0.1
	
	# 更新Timer设置
	age_pass.wait_time = current_cycle_time
	age_pass.start(new_time_left)
	
	print("时间速度调整为：", speed_multiplier, "倍速（", current_cycle_time, "秒/岁），剩余时间：", new_time_left, "秒，已流逝：", time_elapsed, "秒")

# Timer超时回调函数
func _on_age_pass_timeout():
	increase_age(1)
	# 重置已流逝时间
	time_elapsed = 0.0
	# 重新启动Timer，使用当前速度下的完整周期时间
	age_pass.wait_time = current_cycle_time
	age_pass.start()

# 增加年龄函数
func increase_age(amount: int = 1):
	var old_age = global_daughter_age
	global_daughter_age += amount
	
	# 发出年龄变化信号
	emit_signal("age_changed", global_daughter_age)
	
	# 检查是否达到或跨越了5岁的节点
	var old_five_year = old_age / 5
	var new_five_year = global_daughter_age / 5
	
	if new_five_year > old_five_year:
		# 触发5岁信号，使用当前年龄而不是计算出的5岁倍数
		var sentences = get_sentences_for_age(global_daughter_age)
		emit_signal("age_five_reached", global_daughter_age, sentences)
	
	print("女儿年龄增长到：", global_daughter_age, "岁")

# 获取指定年龄的句子数组
func get_sentences_for_age(age: int) -> Array:
	if age_texts.has(age):
		return age_texts[age]
	return []

# 获取当前年龄的句子数组
func get_current_sentences() -> Array[String]:
	return get_sentences_for_age(global_daughter_age)

# 获取全局女儿年龄
func get_daughter_age() -> int:
	return global_daughter_age

# 设置女儿年龄
func set_daughter_age(age: int):
	var old_age = global_daughter_age
	global_daughter_age = max(0, age)
	
	# 发出年龄变化信号
	emit_signal("age_changed", global_daughter_age, old_age)
	
	# 检查是否达到5岁节点
	var current_five_year = global_daughter_age / 5
	var old_five_year = old_age / 5
	
	if current_five_year > old_five_year:
		var current_five_age = current_five_year * 5
		var sentences = get_sentences_for_age(current_five_age)
		emit_signal("age_five_reached", current_five_age, sentences)
	
	print("女儿年龄设置为：", global_daughter_age, "岁")

# 检查是否达到最大年龄
func is_max_age() -> bool:
	return global_daughter_age >= 100

# 获取年龄百分比
func get_age_percentage() -> float:
	return float(global_daughter_age) / 100.0 * 100.0
