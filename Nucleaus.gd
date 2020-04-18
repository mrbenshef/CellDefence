extends StaticBody2D

signal open_nucleaus_shop

var is_mouse_over: bool = false

func _ready():
	pass

func _process(delta):
	if is_mouse_over && Input.is_action_just_pressed("interact"):
		emit_signal("open_nucleaus_shop")

func _on_Nucleaus_mouse_entered():
	print("mouse entered nucleaus")
	is_mouse_over = true

func _on_Nucleaus_mouse_exited():
	print("mouse exited nucleaus")
	is_mouse_over = false
