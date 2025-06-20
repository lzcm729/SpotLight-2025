extends Panel

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func settext(text: String):
	if label:
		label.text = text
	# 启动Timer，时间到后自动消失
	if timer:
		timer.timeout.connect(_on_timer_timeout)
		timer.start()

func _on_timer_timeout():
	# Timer超时后自动消失
	queue_free()
