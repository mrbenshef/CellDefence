extends KinematicBody2D

export (PackedScene) var Protein

export var SPEED : int = 80
export var ACCELERATION : int = 500
export var FRICTION : int = 500
export var BOUNCE : int = 100
export var ROTATION_SPEED : int = 9.0

var target = null
var velocity : Vector2 = Vector2.ZERO

func _ready():
	add_to_group("dna")
	pass

func _process(delta):
	if (target - position).length() < 10.0:
		queue_free()

func _physics_process(delta):	
	if target == null:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		var direction = (target - position).normalized()
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
		
	velocity = move_and_slide(velocity)
	
	# Point towards direction of travel / target
	if target != null:
		rotation = lerp(rotation, target.angle_to_point(position), delta * ROTATION_SPEED)
	else:
		rotation = lerp(rotation, velocity.angle(), delta * ROTATION_SPEED)
		
	# Detect collisions
	var slide_count = get_slide_count()
	for i in range(slide_count):
		var collision = get_slide_collision(i)
		if collision == null:
			break
			
		if collision.collider.is_in_group("dna"):
			break
		
		# Bounce off object
		velocity = collision.normal * BOUNCE	
		
		if target != collision.collider.position:
			# We bumped into somthing, ATTACK!
			print("DNA, new target")
			var new_target = collision.collider.position
			set_target(new_target)
			break
			
			
func set_target(new_target):
	target = new_target

func _on_Area2D_body_entered(body):
	for i in range(randi() % 4 + 1):
		# Peterb the position, space them out a bit
		var peterb : Vector2 = Vector2.ZERO
		peterb.x = rand_range(-5.0, 5.0)
		peterb.y = rand_range(-5.0, 5.0)
		
		var protein = Protein.instance()
		protein.position = position + peterb
		get_tree().current_scene.add_child(protein)
		
	queue_free()
