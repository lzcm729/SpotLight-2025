extends Control
class_name UpgradeCard
@onready var upgrade_content: Label = $VBoxContainer/UpgradeContent
@onready var record: Label = $VBoxContainer/Record

signal upgrade_selected(upgrade: Dictionary)


func update_card_info(upgrade_content_text: String, record_text: String):
	upgrade_content.text = upgrade_content_text
	record.text = record_text

#选择按钮加一个点击信号
func _on_select_pressed() -> void:
	upgrade_selected.emit()
