extends KinematicBody2D

signal shoot_bullet
signal protein_pickup
signal place_turret
signal inventory_update

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
export (PackedScene) var HeldItem

onready var nucleaus_position = get_parent().get_node("Nucleaus").global_position
onready var HUD = get_parent().get_node("HUD")

var state = FLYING
var velocity : Vector2 = Vector2.ZERO
var input_enabled : bool = true

var held_item = null
var held_item_idx : int = -1
var inventory : Array = []

onready var guns: Array = [$Gun1, $Gun2, $Gun3]
var guns_unlocked: Array = [false, true, false]

func _ready():
	for _i in range(9):
		inventory.append("empty")
	emit_signal("inventory_update", inventory)

func add_to_inventory(item):
	for i in range(inventory.size()):
		if inventory[i] != "empty":
			continue
			
		# Found an empty slot, insert
		inventory[i] = item
		emit_signal("inventory_update", inventory)
		return true
	# No empty slots :(
	return false

func remove_from_inventory(idx):
	if idx >= 0 && idx <= 9:
		inventory[idx] = "empty"
		emit_signal("inventory_update", inventory)
		return true
	return false

func set_held_item(idx):
	# Remove previosly held item
	if held_item != null:
		held_item.queue_free()
	
	# Switch to empty, return to flying state
	if inventory[idx] == "empty":
		held_item = null
		held_item_idx = -1
		state = FLYING
		return
	
	held_item_idx = idx
	
	# instance HeldItem
	held_item = HeldItem.instance()
	held_item.set_texture(TurretTexture)
	held_item.position = get_local_mouse_position()
	held_item.set_collision_radius(60)
	add_child(held_item)
	
	# move to PLACING mode
	state = PLACING

func _process(delta):
	HUD.set_tooltip("", false)
	
	if !input_enabled:
		return
		
	var mouse_pos = get_local_mouse_position()
	var is_valid_placement_position : bool = false
		
	# Move held item to mouse position
	if held_item != null:
		held_item.position = mouse_pos
		(held_item as Node2D).global_rotation = 0
		
		# Check if we are in a valid spot
		var too_close_to_nucleaus = (get_global_mouse_position() - nucleaus_position).length() < 300
		var too_close_to_structure = held_item.is_colliding()
		if too_close_to_nucleaus:
			HUD.set_tooltip("to close to nucleaus!", true)
		elif too_close_to_structure:
			HUD.set_tooltip("too close to existing structure", true) 
		
		is_valid_placement_position = !too_close_to_nucleaus && !too_close_to_structure
		
		# Color green/red
		held_item.set_is_good_spot(is_valid_placement_position)
		
	# Select inventory item
	for i in range(9):
		if Input.is_action_just_pressed("item_" + str(i + 1)):
			set_held_item(i)
			# if two buttons where pressed at the same time, 
			# we select the lowest
			break
		
	# Shoot/place item
	if Input.is_action_just_pressed("shoot"):
		match state:
			FLYING:
				for i in range(guns.size()):
					if guns_unlocked[i]:
						emit_signal("shoot_bullet", guns[i].global_position, rotation, velocity)
			PLACING:
				if held_item == null || !is_valid_placement_position:
					return
				print("placing turret")
				emit_signal("place_turret", get_global_mouse_position(), 0)
				remove_from_inventory(held_item_idx)
				held_item.queue_free()
				held_item = null
				held_item_idx = -1
				
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
