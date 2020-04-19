extends RigidBody2D

var pierce : bool = false

func _ready():
	$DespawnTimer.start()

func _on_DespawnTimer_timeout():
	queue_free()
