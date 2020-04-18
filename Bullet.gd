extends RigidBody2D

func _ready():
	$DespawnTimer.start()

func _on_DespawnTimer_timeout():
	queue_free()
