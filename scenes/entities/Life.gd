extends Area2D

func _on_Life_body_exited(body):
	if body.has_method("death"):
		body.death()