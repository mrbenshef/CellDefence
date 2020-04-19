extends Area2D


func _ready():
	pass

func set_texture(texture):
	$Sprite.texture = texture
	$Sprite.modulate = Color(1.0, 1.0, 1.0, 0.5)

func set_is_good_spot(is_good):
	if is_good:
		$Sprite.modulate = Color(0.0, 1.0, 0.0, 0.5)
	else:
		$Sprite.modulate = Color(1.0, 0.0, 0.0, 0.5)

func set_collision_radius(radius):
	$CollisionShape2D.shape.radius = radius

func is_colliding():
	return get_overlapping_bodies().size() > 0
