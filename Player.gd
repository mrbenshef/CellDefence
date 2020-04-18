extends KinematicBody2D

signal shoot_bullet

export var SPEED : int = 80
export var ACCELERATION : int = 500
export var FRICTION : int = 500

onready var Gun : Position2D = $Gun

var velocity : Vector2 = Vector2.ZERO

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		print("shoot!")
		emit_signal("shoot_bullet", Gun.global_position, rotation - PI / 2)

func _physics_process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var target_angle = position.angle_to_point(mouse_pos) - PI / 2
	rotation = target_angle

	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	
	velocity = move_and_slide(velocity)
