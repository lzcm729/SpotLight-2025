extends Panel
@onready var num: Label = $Num
@onready var get_state: Label = $GetState

func test_show_id(id: int):
	num.text = str(id)
	
func change_get_state(is_get:bool):
	get_state.visible = is_get
