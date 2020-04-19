extends StaticBody2D

signal open_nucleaus_shop
signal nucleaus_dead

var is_mouse_over: bool = false

export (int) var MAX_HEALTH = 1000
var health : int

func _ready():
	health = MAX_HEALTH
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
		emit_signal("nucleaus_dead")
	$HealthBar.set_health(health)
