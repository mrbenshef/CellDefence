extends KinematicBody2D

signal shoot_bullet
signal protein_pickup
signal place_turret

enum {
	FLYING
	PLACING
}

const WALL_COLLISION_BIT = 2

export var SPEED : int = 80
export var ACCELERATION : int = 500
export var FRICTION : int = 500
export var BOUNCE : int = 300
export var ROTATION_SMOOTHING : float = 0.1

export (Texture) var TurretTexture : Texture

onready var Gun : Position2D = $Gun

var state = FLYING
var velocity : Vector2 = Vector2.ZERO
var input_enabled : bool = true
var held_item = null

func _process(delta):
	if !input_enabled:
		return
		
	var mouse_pos = get_local_mouse_position()
		
	# Move held item to mouse position
	if held_item != null:
		held_item.position = mouse_pos
		(held_item as Node2D).global_rotation = 0
		
	# Select inventory item
	if Input.is_action_just_pressed("item_1"):
		var sprite : Sprite = Sprite.new()
		sprite.texture = TurretTexture
		sprite.modulate = Color(1.0, 1.0, 1.0, 0.5)
		var node : Node2D = Node2D.new()
		node.position = mouse_pos
		node.add_child(sprite)
		add_child(node)
		held_item = node
		state = PLACING
		
	# Shoot/place item
	if Input.is_action_just_pressed("shoot"):
		match state:
			FLYING:
				emit_signal("shoot_bullet", Gun.global_position, rotation)
			PLACING:
				if held_item == null:
					return
				print("placing turret")
				emit_signal("place_turret", get_global_mouse_position(), 0)
				held_item.queue_free()
				held_item = null
				state = FLYING

func _physics_process(delta):
	var input_vector : Vector2 = Vector2.ZERO
	
	if input_enabled:
		# Point to mouse
		var mouse_pos = get_local_mouse_position()
		rotation += mouse_pos.angle() * ROTATION_SMOOTHING
		
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

func _on_Magnet_body_entered(body):
	emit_signal("protein_pickup")
	body.set_target(self)
