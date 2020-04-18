extends KinematicBody2D

signal shoot_bullet

const WALL_COLLISION_BIT = 2

export var SPEED : int = 80
export var ACCELERATION : int = 500
export var FRICTION : int = 500
export var BOUNCE : int = 300
export var ROTATION_SMOOTHING : float = 0.1

# onready var Wall : Wall = preload("res://Wall.tscn")

onready var Gun : Position2D = $Gun

var velocity : Vector2 = Vector2.ZERO

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		print("shoot!")
		emit_signal("shoot_bullet", Gun.global_position, rotation)

func _physics_process(delta):
	var mouse_pos = get_local_mouse_position()
	rotation += mouse_pos.angle() * ROTATION_SMOOTHING

	var input_vector : Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()
	
	if input_vector == Vector2.ZERO:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		velocity = velocity.move_toward(input_vector * SPEED, ACCELERATION * delta)
	
	velocity = move_and_slide(velocity)
	
	var slide_count = get_slide_count()
	if slide_count > 0:
		for i in range(slide_count):
			var collision = get_slide_collision(i)
			if collision == null:
				continue
			
			# Check we are colliding with a wall
			var collider : PhysicsBody2D = collision.collider
			if !collider.get_collision_layer_bit(WALL_COLLISION_BIT):
				continue
			
			# Bounce!
			velocity = collision.normal * BOUNCE
				
