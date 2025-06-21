extends Control
class_name Dialog

signal next_dialog_requested  # 请求显示下一句的信号
signal dialog_completed  # 所有对话显示完毕的信号

@onready var content: Label = $Content
@onready var texture_rect: TextureRect = $TextureRect
@onready var panel: Panel = $Panel  # 假设Panel是根节点或直接子节点

# 对话内容管理
var dialog_list: Array = []
var current_dialog_index: int = 0
var is_dialog_active: bool = false

func _ready():
	# 连接Panel的点击事件
	if panel:
		panel.gui_input.connect(_on_panel_gui_input)

# 开始显示对话列表
func start_dialog(dialog_texts: Array):
	dialog_list = dialog_texts
	current_dialog_index = 0
	is_dialog_active = true
	
	# 显示对话框
	set_dialog_visible(true)
	
	# 显示第一句对话
	if dialog_list.size() > 0:
		set_dialog_text(dialog_list[0])
		print("Dialog: 开始对话，共 ", dialog_list.size(), " 句")
	else:
		complete_dialog()

# 显示下一句对话
func show_next_dialog():
	if not is_dialog_active:
		return
	
	current_dialog_index += 1
	
	if current_dialog_index < dialog_list.size():
		# 还有更多对话
		set_dialog_text(dialog_list[current_dialog_index])
		print("Dialog: 显示第 ", current_dialog_index + 1, " 句对话")
	else:
		# 所有对话显示完毕
		complete_dialog()

# 完成对话
func complete_dialog():
	is_dialog_active = false
	set_dialog_visible(false)
	dialog_completed.emit()
	print("Dialog: 对话完成")

# 修改对话框文本内容
func set_dialog_text(text: String):
	if content:
		content.text = text
		print("Dialog: 设置文本内容: ", text)

# 清空文本内容
func clear_dialog_text():
	if content:
		content.text = ""
		print("Dialog: 清空文本内容")

# 设置对话框可见性
func set_dialog_visible(visible: bool):
	self.visible = visible
	print("Dialog: 设置可见性: ", visible)

# Panel点击事件处理
func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_dialog_active:
				# 显示下一句对话
				show_next_dialog()
			print("Dialog: 点击Panel")

# 获取当前对话进度
func get_dialog_progress() -> Dictionary:
	return {
		"current_index": current_dialog_index,
		"total_count": dialog_list.size(),
		"is_active": is_dialog_active,
		"current_text": content.text if content else ""
	}

# 检查是否正在显示对话
func is_showing_dialog() -> bool:
	return is_dialog_active

# 跳过当前对话（直接完成）
func skip_dialog():
	if is_dialog_active:
		complete_dialog()
