extends StaticBody2D

signal shoot_bullet

export var MAX_HEALTH : int = 100
export var health : int = 100

func _ready():
	add_to_group("damageable")
	$HealthBar.set_max_health(MAX_HEALTH)
	$HealthBar.set_health(health)
	pass

func _on_Cooldown_timeout():
	var targets = $RangeArea2D.get_overlapping_bodies()
	if targets.empty():
		return

	var i = randi() % targets.size()
	var target = targets[i]
	
	var bullet_start = $GunPosition2D.global_position
	var bullet_rotation = bullet_start.angle_to_point(target.global_position) + PI
	
	print("shooting at angle", bullet_rotation)
	emit_signal("shoot_bullet", bullet_start, bullet_rotation)

func damage(amount):
	health -= amount
	if health <= 0:
		queue_free()
	$HealthBar.set_health(health)
	
