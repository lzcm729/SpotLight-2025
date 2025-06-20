extends Control
@onready var age = $Age
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var speedup: Button = $Speedup
@onready var speed_down: Button = $SpeedDown
@onready var sentence_list: VBoxContainer = $SentenceList
@onready var create_timer: Timer = $SentenceList/CreateTimer

# 句子UI预制体
@export var sentence_ui_scene: PackedScene

# 句子队列
var sentence_queue: Array[String] = []

func _ready() -> void:
	speedup.pressed.connect(_on_speedup_pressed)
	speed_down.pressed.connect(_on_speed_down_pressed)

	update_age_display(DaughterManager.global_daughter_age)
	DaughterManager.age_changed.connect(update_age_display)
	DaughterManager.age_five_reached.connect(_on_age_five_reached)
	
	# 设置进度条与Timer同步
	setup_timer_progress_bar()
	
	# 设置句子生成Timer
	setup_sentence_timer()

func _on_speedup_pressed():
	DaughterManager.time_speed += 0.5
	DaughterManager.set_time_speed(DaughterManager.time_speed)

func _on_speed_down_pressed():
	DaughterManager.time_speed -= 0.5
	DaughterManager.set_time_speed(DaughterManager.time_speed)
	
func update_age_display(new_age: int):
	age.text = "当前年龄：" + str(new_age) + "岁"

# 设置句子生成Timer
func setup_sentence_timer():
	create_timer.wait_time = 1.0  # 每1秒生成一个句子
	create_timer.timeout.connect(_on_create_timer_timeout)

# 处理5岁信号
func _on_age_five_reached(age: int, sentences: Array):
	# 将新句子添加到队列
	for sentence in sentences:
		sentence_queue.append(sentence)
	
	# 如果Timer没有运行，开始生成句子
	if not create_timer.is_stopped():
		return
	
	# 开始生成第一个句子
	generate_next_sentence()

# 生成下一个句子
func generate_next_sentence():
	if sentence_queue.size() > 0:
		var sentence_text = sentence_queue.pop_front()
		create_sentence_ui(sentence_text)
		
		# 如果队列中还有句子，启动Timer生成下一个
		if sentence_queue.size() > 0:
			create_timer.start()
		else:
			# 队列为空，停止Timer
			create_timer.stop()

# 句子生成Timer超时
func _on_create_timer_timeout():
	generate_next_sentence()

# 清空句子列表
func clear_sentence_list():
	for child in sentence_list.get_children():
		child.queue_free()

# 创建句子UI
func create_sentence_ui(sentence_text: String):
	if sentence_ui_scene:
		var sentence_ui = sentence_ui_scene.instantiate()
		sentence_list.add_child(sentence_ui)
		
		# 调用settext函数设置文本
		if sentence_ui.has_method("settext"):
			sentence_ui.settext(sentence_text)

func setup_timer_progress_bar():
	# 设置进度条最大值（10秒）
	progress_bar.max_value = 10.0
	progress_bar.min_value = 0.0
	
	# 连接Timer的timeout信号来更新进度条
	DaughterManager.age_pass.timeout.connect(_on_timer_timeout)
	
	# 开始更新进度条
	update_timer_progress()

func update_timer_progress():
	# 使用DaughterManager的真实Timer信息
	var time_left = DaughterManager.get_real_time_left()
	var total_time = DaughterManager.get_real_cycle_time()
	
	# 计算进度：已过去的时间 / 总时间
	var elapsed_time = total_time - time_left
	var progress = elapsed_time / total_time
	
	# 更新进度条值（0-10范围）
	progress_bar.value = progress * 10.0

func _on_timer_timeout():
	# Timer结束时重置进度条
	progress_bar.value = 0.0

func _process(delta):
	# 实时更新进度条
	update_timer_progress()
