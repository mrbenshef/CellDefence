extends ColorRect

func _ready():
	visible = true

func _on_CloseButton_pressed():
	visible = false
