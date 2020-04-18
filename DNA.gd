extends KinematicBody2D

export (PackedScene) var Protein

export var SPEED : int = 80
export var ACCELERATION : int = 500
export var FRICTION : int = 500

var target = null
var velocity : Vector2 = Vector2.ZERO

func _ready():
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
