extends StaticBody2D

signal open_nucleaus_shop

var is_mouse_over: bool = false

export (int) var MAX_HEALTH = 1000
var health : int = MAX_HEALTH

func _ready():
	add_to_group("damageable")
	$HealthBar.set_max_health(MAX_HEALTH)
	$HealthBar.set_health(health)

func _process(delta):
	if is_mouse_over && Input.is_action_just_pressed("interact"):
		emit_signal("open_nucleaus_shop")

func _on_Nucleaus_mouse_entered():
	print("mouse entered nucleaus")
	is_mouse_over = true

func _on_Nucleaus_mouse_exited():
	print("mouse exited nucleaus")
	is_mouse_over = false

func damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
	$HealthBar.set_health(health)
