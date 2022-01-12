extends Area2D

func _on_Death_body_entered(body):
	if get_parent().get_node("Paddle").started && body.has_method("death"):
		body.death()
