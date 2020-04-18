extends Node2D

export var LANDING_TIME : float = 3.0
export var LANDING_HEIGHT : float = 300.0

func launch():
	print("launch!")
	var start_position = position
	start_position.y -= LANDING_HEIGHT * cos(rotation)
	start_position.x += LANDING_HEIGHT * sin(rotation)
	$Tween.interpolate_property(self, "position", start_position, position, LANDING_TIME, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()
