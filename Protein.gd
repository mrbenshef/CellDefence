extends KinematicBody2D

export var SPEED : float = 0.8

var target = null
var time : float = 0

func _process(delta):
	if target != null:
		if time >= 1.0 || distance_to_target() < 2 :
			queue_free()

func distance_to_target():
	return (target.position - position).length()

func _physics_process(delta):
	if target != null:
		time += delta * SPEED
		position = position.linear_interpolate(target.position, time)

func set_target(new_target):
	target = new_target
	$CollisionShape2D.disabled = true
