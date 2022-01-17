extends Area2D

var powerup_type = 1

func _process(delta):
	self.position.y += delta * 250

func _on_Powerup_body_entered(body):
	if body.is_in_group("Paddle"):
		body.upgrade(powerup_type)
		self.call_deferred("queue_free")


func _on_Timer_timeout():
	self.call_deferred("queue_free")
