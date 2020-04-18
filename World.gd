extends Node2D

export (PackedScene) var BULLET

func _ready():
	pass

func _on_Player_shoot_bullet(pos, rot):
	var bullet : RigidBody2D = BULLET.instance()
	bullet.position = pos
	bullet.rotation = rot
	bullet.linear_velocity = Vector2(cos(rot), sin(rot)) * 300
	print(bullet)
	
	add_child(bullet)
