extends StaticBody2D

signal shoot_bullet

func _ready():
	pass

func _on_Cooldown_timeout():
	return
	var targets = $RangeArea2D.get_overlapping_bodies()
	if targets.empty():
		return
	
	var i = randi() % targets.size()
	var target = targets[i]
	
	var bullet_start = $GunPosition2D.global_position
	var bullet_rotation = bullet_start.angle_to_point(target.global_position) + PI
	
	print("shooting at angle", bullet_rotation)
	emit_signal("shoot_bullet", bullet_start, bullet_rotation)
