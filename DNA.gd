extends KinematicBody2D

export (PackedScene) var Protein

export var SPEED : int = 80
export var ACCELERATION : int = 500
export var FRICTION : int = 500
export var BOUNCE : int = 100
export var ROTATION_SPEED : int = 9.0
export var MAX_MAX_HEALTH : int = 5

var max_health = 100
var health = max_health

func set_max_health(h):
	max_health = h
	if health > h:
		health = h

var target = null
var velocity : Vector2 = Vector2.ZERO
var target_offset : Vector2 = Vector2.ZERO

func _ready():
	$Sprite.modulate = target_color(0)
	add_to_group("dna")
	
func target_color(h):
	return lerp(Color(0.8, 0.2, 0.2, 1.0), Color(0.2, 0.2, 0.8, 1.0), h / float(MAX_MAX_HEALTH))

func _process(delta):
	$Sprite.modulate = lerp($Sprite.modulate, target_color(health), delta * 20)
	
	var distance_to_target = (target - position).length()
	if distance_to_target < 10.0:
		queue_free()
	elif distance_to_target < 100.0:
		target_offset = Vector2.ZERO

func _physics_process(delta):	
	if target == null:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	else:
		var direction = ((target + target_offset) - position).normalized()
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
		
	velocity = move_and_slide(velocity)
	
	# Point towards direction of travel / target
	if target != null:
		rotation = lerp(rotation, (target + target_offset).angle_to_point(position), delta * ROTATION_SPEED)
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
		
		if collision.collider.is_in_group("damageable"):
			if $AttackCooldownTimer.is_stopped():
				collision.collider.damage(1)
				$AttackCooldownTimer.start() # stops attack until cooldown elapsed
		
			# Bounce off object
			velocity = collision.normal * BOUNCE	
		
		if target != collision.collider.position:
			if collision.collider.is_in_group("damageable"):
				# We bumped into somthing, ATTACK!
				print("DNA, new target")
				var new_target = collision.collider.position
				set_target(new_target)
				break
			else:
				target_offset += Vector2.LEFT * 20
				pass
			
func set_target(new_target):
	target = new_target
	target_offset = Vector2(rand_range(-300, 300), rand_range(-300, 300))

func _on_Area2D_body_entered(body):	
	if !body.pierce:
		body.queue_free()
		
	health -= body.damage
	if health > 0:
		return
		
	for i in range(randi() % 8 + 4):
		# Peterb the position, space them out a bit
		var peterb : Vector2 = Vector2.ZERO
		peterb.x = rand_range(-5.0, 5.0)
		peterb.y = rand_range(-5.0, 5.0)
		
		var protein = Protein.instance()
		protein.position = position + peterb
		get_tree().current_scene.get_node("Protein").add_child(protein)
	
	$AudioStreamPlayer2D.play()
	queue_free()


func _on_SenseTimer_timeout():
	target_offset *= 0.5

