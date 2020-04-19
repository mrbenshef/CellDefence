extends Node2D

export var LANDING_TIME : float = 3.0
export var LANDING_HEIGHT : float = 300.0

enum {
	START,
	LANDING,
	LAUNCHING
}

var state = START


func land():
	state = LANDING
	var start_position = position
	start_position.y -= LANDING_HEIGHT * cos(rotation)
	start_position.x += LANDING_HEIGHT * sin(rotation)
	$Tween.interpolate_property(self, "position", start_position, position, LANDING_TIME, Tween.TRANS_QUART, Tween.EASE_OUT)
	$Tween.start()

func launch():
	state = LAUNCHING
	var end_position = position
	end_position.y -= LANDING_HEIGHT * cos(rotation)
	end_position.x += LANDING_HEIGHT * sin(rotation)
	$Tween.interpolate_property(self, "position", position, end_position, LANDING_TIME, Tween.TRANS_QUART, Tween.EASE_IN)
	$Tween.start()


func _on_Tween_tween_completed(object, key):
	if state == LAUNCHING:
		queue_free()
