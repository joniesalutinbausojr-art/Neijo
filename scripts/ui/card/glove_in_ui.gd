extends TextureRect
class_name UIGlove

@onready var glove: TextureRect = $Glove

func _on_button_pressed() -> void:
	glove.visible = false
	EventBus.push_event("main_game_click_glove")

func ui_glove_appear():
	glove.visible = true
