extends Control
@onready var upgrade_content: Label = $VBoxContainer/UpgradeContent
@onready var record: Label = $VBoxContainer/Record



func update_card_info(upgrade_content_text: String, record_text: String):
	upgrade_content.text = upgrade_content_text
	record.text = record_text
