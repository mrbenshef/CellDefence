extends Node2D

export var MAX_HEALTH : int = 100

func _ready():
	$TextureProgress.max_value = MAX_HEALTH
	$TextureProgress.value = MAX_HEALTH
	pass

func set_max_health(new_max):
	$TextureProgress.max_value = new_max
	
func set_health(new_health):
	$TextureProgress.value = new_health
