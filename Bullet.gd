extends RigidBody2D

var pierce : bool = false
var damage : int = 1

func _ready():
	$DespawnTimer.start()

func _on_DespawnTimer_timeout():
	queue_free()
