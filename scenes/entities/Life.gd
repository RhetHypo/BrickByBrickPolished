extends Area2D

func _on_Life_body_exited(body):
	if get_parent().get_node("Paddle").started && body.has_method("death") && !body.temp_alive:
		body.death()