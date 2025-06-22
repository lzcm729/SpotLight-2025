extends Node

# 全局存储女儿当前年龄
var global_daughter_age: int = 8
var time_speed: float = 1.0
@onready var age_pass: Timer = $AgePass

@export var space_ship: SpaceShip
@export var black_hole: BlackHole

# var messages = {
# 	10: "今天我学会了做纸飞机，想着你是不是也会做。我想你一定很厉害，一定能做出比我更远的飞机吧。什么时候回来教我做更多有趣的东西呀？我好想你！",
# 	11: "我今天学会了骑自行车！虽然摔了好几次，但我还是很开心。你说过，跌倒了就要爬起来。我会一直记住的！我希望你能回来陪我一起骑车，带我去看更远的地方。",
# 	12: "我在学校里得了第一名！老师说我很聪明，我想这一定是因为你教会了我很多东西。我希望你能回来看看我，看看我长大了多少。我会继续努力学习，成为一个像你一样优秀的人！",
# 	13: "我看到一个小女孩的爸爸来接她放学，我真的好难过。为什么你从来不来接我呢？你说过我可以像别的孩子一样有爸爸陪着，但我从来没有见过你。你再不回来我都不想理你了！",
# 	14: "我今天在学校被同学们笑话了，说我又在天文课上讲你讲过的故事。你知道吗？我觉得他们不懂得有趣的东西。我好奇你现在是不是也在外星，为什么还不回来呢？大家都说你可能去外星了，但我不相信，爸爸怎么可能这么久都不回家。",
# 	15: "我给老师写了你是宇航员的故事，老师说"太空不真实"，我很生气！我觉得我可以告诉她你是多么伟大，为什么你要走那么久？为什么你不陪我一起过生日呢？好气哦！",
# 	16: "你怎么又没回来！每年过生日我都许愿，希望你能回家，但是你总是没回来。妈妈说你在做很重要的事，可我真的不理解为什么不能放下这些事情，回来看看我。怎么样？你就这么忙吗？",
# 	17: "我今天在学校里参加了一个演讲比赛，我讲了一个关于梦想的故事。虽然我没有得奖，但我很开心。我希望你能回来听我讲这个故事，给我一些建议。我会继续努力，让自己变得更好。你是我最崇拜的人，我希望能像你一样出色！",
# 	18: "我觉得我开始不需要你了，学校的事情我一个人能应付，妈妈也能照顾我。你这样一直不回来，我有时候都觉得你根本不在乎我。你去做你的任务吧，我反正已经不期待你回来了。",
# 	19: "我今天在学校里参加了一个毕业典礼，我收到了毕业证书。虽然我还没有完全准备好，但我知道这是一个新的开始。",
# 	20: "我已经长大了。大学的日子很充实，虽然有很多挑战，但我始终记得你告诉过我，面对困难不能轻言放弃。每次看到天空，我都会想着你是不是也在某个遥远的星系中，想着我们。不管多久，你一定要记得，家里永远等着你，等你回来。",
# 	22: "我已经是成年人了，生活里有了很多自己的责任。我会常常想起你，想象你是否依然在黑洞的边缘努力着。你不在的时候，我学会了独自坚强，也学会了理解你的选择。你为全人类付出了那么多，我始终明白，这一切不容易。希望你在某个地方也能感受到我的思念。",
# 	25: "我已经25岁了，生活中有了更多的挑战和责任。我开始理解你当初为什么要离开。虽然你不在身边,但我知道你一直在为我们而努力。我会继续前行，带着你的精神和勇气。",
# 	30: "我变成了母亲。每次看到我的孩子，我就会想，如果你也能看到他们，那该多好。你说过，要为了人类的未来去做最艰难的决定，我理解你了。虽然你没有回来，但我知道你在做一件重要的事。",
# 	40: "这些年我经历了很多，孩子们也长大了。有时我想，若你能在这里看着我们成长，或许一切会更完整。但我知道，这些是你必须承担的责任。我理解了，也接受了。你所做的牺牲，永远铭刻在我的心里。",
# 	45: "我不再是当年那个渴望你回来的小女孩了，岁月已让我们彼此改变。我的孩子也成家了，我总是给他们讲你是如何为了人类未来而奋不顾身的。无论你在何处，我都希望你能知道，我一直在这里，怀着对你的敬意和爱。",
# 	50: "我已经变得很老了，生活也进入了平静的阶段。你可能不知道，这些年来我依旧会想起你，想着你为了全人类的未来，放弃了和我一起度过的日子。我希望你知道，我明白你当时做出的选择，也为你感到骄傲。",
# 	60: "我已经60岁了，回首一生，我感到无比的满足和骄傲。虽然你没有陪伴我走过每一个重要的时刻，但我知道你一直在为人类的未来而奋斗。你的牺牲和奉献让我深感敬佩。我希望你能看到我现在的生活，我会继续传承你的精神，让我们的故事永远流传下去。"
# } as Dictionary[int, String]

# 时间流逝相关变量
var time_elapsed: float = 0.0  # 当前周期内已经流逝的时间
var base_cycle_time: float = 10.0  # 基础周期时间（1倍速时的周期，10秒/岁）
var current_cycle_time: float = 10.0  # 当前周期时间
var is_in_black_hole_range: bool = false  # 是否在黑洞影响范围内
var min_speed_multiplier: float = 1.0  # 最小速度倍数（最远距离）
var max_speed_multiplier: float = 2.0  # 最大速度倍数（最近距离）

# 年龄文本字典，索引直接对应年龄，每5岁存储2-3条文本内容
var age_texts: Dictionary = {

	10: [
		"今天我学会了做纸飞机，想着你是不是也会做。", "我想你一定很厉害，一定能做出比我更远的飞机吧。","什么时候回来教我做更多有趣的东西呀？我好想你！"
	],
	11: [
		"我今天学会了骑自行车！","虽然摔了好几次，但我还是很开心。","你说过，跌倒了就要爬起来。我会一直记住的！","我希望你能回来陪我一起骑车，带我去看更远的地方。"
	],
	12: [
		"我在学校里得了第一名！","老师说我很聪明，我想这一定是因为你教会了我很多东西。","我希望你能回来看看我，看看我长大了多少。","我会继续努力学习，成为一个像你一样优秀的人！"
	],
	13: [
		"我看到一个小女孩的爸爸来接她放学，我真的好难过。","为什么你从来不来接我呢？","你说过我可以像别的孩子一样有爸爸陪着，但我从来没有见过你。","你再不回来我都不想理你了！"
	],
	14: [
		"我今天在学校被同学们笑话了，说我又在天文课上讲你讲过的故事。","你知道吗？我觉得他们不懂得有趣的东西。","我好奇你现在是不是也在外星，为什么还不回来呢？","大家都说你可能去外星了，但我不相信，爸爸怎么可能这么久都不回家。"
	],
	15: [
		"我给老师写了你是宇航员的故事，老师说太空不真实，我很生气！","我觉得我可以告诉她你是多么伟大，为什么你要走那么久？","为什么你不陪我一起过生日呢？","好气哦！"
	],
	16: [
		"你怎么又没回来！","每年过生日我都许愿，希望你能回家，但是你总是没回来。","妈妈说你在做很重要的事，可我真的不理解为什么不能放下这些事情，回来看看我。","怎么样？你就这么忙吗？"
	],
	17: [
		"我今天在学校里参加了一个演讲比赛，我讲了一个关于梦想的故事。","虽然我没有得奖，但我很开心。","我希望你能回来听我讲这个故事，给我一些建议。"
	],
	18: [
		"我觉得我开始不需要你了，学校的事情我一个人能应付，妈妈也能照顾我。","你这样一直不回来，我有时候都觉得你根本不在乎我。","你去做你的任务吧，我反正已经不期待你回来了。"
	],
	19: [
		"我今天在学校里参加了一个毕业典礼，我收到了毕业证书。","虽然我还没有完全准备好，但我知道这是一个新的开始。"
	],
	20: [
		"我已经长大了。","大学的日子很充实，虽然有很多挑战，但我始终记得你告诉过我，面对困难不能轻言放弃。","每次看到天空，我都会想着你是不是也在某个遥远的星系中，想着我们。","不管多久，你一定要记得，家里永远等着你，等你回来。"
	],
	22: [
		"我已经是成年人了，生活里有了很多自己的责任。","我会常常想起你，想象你是否依然在黑洞的边缘努力着。","你不在的时候，我学会了独自坚强，也学会了理解你的选择。","你为全人类付出了那么多，我始终明白，这一切不容易。","希望你在某个地方也能感受到我的思念。"
	],
	25: [
		"我已经25岁了，生活中有了更多的挑战和责任。","我开始理解你当初为什么要离开。","虽然你不在身边,但我知道你一直在为我们而努力。","我会继续前行，带着你的精神和勇气。"
	],
	30: [
		"我变成了母亲。","每次看到我的孩子，我就会想，如果你也能看到他们，那该多好。","你说过，要为了人类的未来去做最艰难的决定，我理解你了。","虽然你没有回来，但我知道你在做一件重要的事。"
	],
	40: [
		"这些年我经历了很多，孩子们也长大了。","有时我想，若你能在这里看着我们成长，或许一切会更完整。","但我知道，这些是你必须承担的责任。","我理解了，也接受了。","你所做的牺牲，永远铭刻在我的心里。"
	],
	45: [
		"我不再是当年那个渴望你回来的小女孩了，岁月已让我们彼此改变。","我的孩子也成家了，我总是给他们讲你是如何为了人类未来而奋不顾身的。","无论你在何处，我都希望你能知道，我一直在这里，怀着对你的敬意和爱。"
	],
	50: [
		"我已经变得很老了，生活也进入了平静的阶段。","你可能不知道，这些年来我依旧会想起你，想着你为了全人类的未来，放弃了和我一起度过的日子。","我希望你知道，我明白你当时做出的选择，也为你感到骄傲。"
	],
	60: [
		"我已经60岁了，回首一生，我感到无比的满足和骄傲。","虽然你没有陪伴我走过每一个重要的时刻，但我知道你一直在为人类的未来而奋斗。","你的牺牲和奉献让我深感敬佩。","我希望你能看到我现在的生活，我会继续传承你的精神，让我们的故事永远流传下去。"
	],
}

# 信号：每当5岁时触发，发送该年龄的所有句子
signal age_five_reached(age: int, sentences: Array[String])
# 信号：每当年龄变化时触发
signal age_changed(new_age: int, old_age: int)

func _ready():
	# 初始化女儿年龄为8岁
	global_daughter_age = 8
	
	# 初始化Timer系统
	initialize_timer_system()
	
	# 初始化时检查是否已在黑洞吸引半径内
	initialize_black_hole_range_check()

# 初始化Timer系统
func initialize_timer_system():
	current_cycle_time = base_cycle_time / time_speed
	age_pass.wait_time = current_cycle_time
	age_pass.timeout.connect(_on_age_pass_timeout)
	# 不立即启动Timer，等待进入黑洞范围
	# 确保Timer初始状态为停止
	age_pass.stop()

# 初始化时检查黑洞范围状态
func initialize_black_hole_range_check():
	# 等待一帧确保所有节点都已准备好
	await get_tree().process_frame
	
	# 检查是否已在黑洞吸引半径内
	var gravity_radius = 0.0
	if black_hole:
		gravity_radius = black_hole.GetAttractionRadius()
	
	var distance_to_black_hole = get_distance_to_black_hole()
	is_in_black_hole_range = distance_to_black_hole <= gravity_radius
	
	# 如果初始化时就在黑洞范围内，立即开始年龄增长
	if is_in_black_hole_range:
		start_age_timer()
		print("初始化检测：已在黑洞引力范围内，开始年龄增长 (距离: ", distance_to_black_hole, ", 引力半径: ", gravity_radius, ")")
	else:
		print("初始化检测：不在黑洞引力范围内，等待进入 (距离: ", distance_to_black_hole, ", 引力半径: ", gravity_radius, ")")

# 检查黑洞影响范围并更新Timer状态
func check_black_hole_range():
	var was_in_range = is_in_black_hole_range
	
	# 使用黑洞的引力半径来判断是否在范围内
	var gravity_radius = 0.0
	if black_hole:
		gravity_radius = black_hole.GetAttractionRadius()
	
	var distance_to_black_hole = get_distance_to_black_hole()
	is_in_black_hole_range = distance_to_black_hole <= gravity_radius
	
	# 如果在黑洞范围内，根据距离调整速度
	if is_in_black_hole_range:
		update_speed_based_on_distance(distance_to_black_hole, gravity_radius)
	
	# 如果状态发生变化
	if is_in_black_hole_range != was_in_range:
		if is_in_black_hole_range:
			# 进入黑洞范围，启动Timer
			start_age_timer()
			print("进入黑洞引力范围，开始年龄增长 (距离: ", distance_to_black_hole, ", 引力半径: ", gravity_radius, ", 当前速度: ", time_speed, "倍)")
		else:
			# 离开黑洞范围，暂停Timer
			pause_age_timer()
			print("离开黑洞引力范围，暂停年龄增长 (距离: ", distance_to_black_hole, ", 引力半径: ", gravity_radius, ")")

# 根据距离更新速度
func update_speed_based_on_distance(distance: float, gravity_radius: float):
	# 计算距离比例（0.0 = 黑洞中心，1.0 = 引力范围边缘）
	var distance_ratio = distance / gravity_radius
	
	# 反转比例，使距离越近速度越快
	var speed_ratio = 1.0 - distance_ratio
	
	# 确保比例在有效范围内
	speed_ratio = clamp(speed_ratio, 0.0, 1.0)
	
	# 计算新的速度倍数（从min_speed_multiplier到max_speed_multiplier）
	var new_speed = min_speed_multiplier + (max_speed_multiplier - min_speed_multiplier) * speed_ratio
	
	# 如果速度发生变化，更新Timer
	if abs(new_speed - time_speed) > 0.01:  # 避免微小变化
		set_time_speed(new_speed)

# 暂停年龄增长Timer
func pause_age_timer():
	if age_pass.is_stopped():
		return  # 如果Timer已经停止，不需要暂停
	
	# 暂停Timer，保持当前进度
	age_pass.paused = true

# 启动年龄增长Timer
func start_age_timer():
	# 只有在黑洞范围内才启动Timer
	if not is_in_black_hole_range:
		return
	
	# 如果Timer被暂停，恢复运行
	if age_pass.paused:
		age_pass.paused = false
		return
	
	# 如果Timer已经停止且没有剩余时间，重新开始
	if age_pass.is_stopped() and age_pass.time_left <= 0:
		age_pass.wait_time = current_cycle_time
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
	
	# 只有在黑洞范围内才调整Timer
	if is_in_black_hole_range:
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
	else:
		# 不在范围内时只更新周期时间，不启动Timer
		current_cycle_time = base_cycle_time / time_speed
	
	# print("时间速度调整为：", speed_multiplier, "倍速（", current_cycle_time, "秒/岁），在黑洞范围内：", is_in_black_hole_range)

# Timer超时回调函数
func _on_age_pass_timeout():
	# 只有在黑洞范围内才增加年龄
	if is_in_black_hole_range:
		increase_age(1)
		# 重置已流逝时间
		time_elapsed = 0.0
		# 重新启动Timer，使用当前速度下的完整周期时间
		age_pass.wait_time = current_cycle_time
		age_pass.start()
	else:
		# 如果不在黑洞范围内，停止Timer
		age_pass.stop()
		print("Timer超时但不在黑洞范围内，停止Timer")

# 增加年龄函数
func increase_age(amount: int = 1):
	var old_age = global_daughter_age
	global_daughter_age += amount
	
	# 发出年龄变化信号
	emit_signal("age_changed", global_daughter_age)
	
	# 检查是否达到有消息的年龄节点
	if age_texts.has(global_daughter_age):
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
	global_daughter_age = max(8, age)  # 最小年龄设为8岁
	
	# 发出年龄变化信号
	emit_signal("age_changed", global_daughter_age, old_age)
	
	# 检查是否达到有消息的年龄节点
	if age_texts.has(global_daughter_age):
		var sentences = get_sentences_for_age(global_daughter_age)
		emit_signal("age_five_reached", global_daughter_age, sentences)
	
	print("女儿年龄设置为：", global_daughter_age, "岁")

# 检查是否达到最大年龄
func is_max_age() -> bool:
	return global_daughter_age >= 60

# 获取年龄百分比
func get_age_percentage() -> float:
	# 从8岁开始计算百分比，最大年龄为60岁（age_texts中的最大年龄）
	var max_age = 60
	var min_age = 8
	return float(global_daughter_age - min_age) / float(max_age - min_age) * 100.0

# 通过飞船获取与黑洞的距离
func get_distance_to_black_hole() -> float:
	if space_ship:
		return space_ship.GetDistanceToBlackHole()
	return 0.0


# 每帧检查黑洞范围
func _process(_delta):
	check_black_hole_range()
	
	# 调试信息：如果Timer在运行但不在黑洞范围内，输出警告
	if not age_pass.is_stopped() and not age_pass.paused and not is_in_black_hole_range:
		print("警告：Timer正在运行但不在黑洞范围内！距离: ", get_distance_to_black_hole(), ", 范围状态: ", is_in_black_hole_range)
