extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_Bullet_body_entered(body):
	self.call_deferred("queue_free")
	if body.is_in_group("Brick"):
		get_parent().award_points(10)
		#brick break logic from ball script, should consider moving to function
		var parent = body.get_parent()
		var anim = parent.get_node("AnimationPlayer")
		body.call_deferred("queue_free")
		parent.get_node("Tween").interpolate_property(parent, "position:x", parent.position.x, parent.position.x + (parent.position.x-self.position.x)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		parent.get_node("Tween").interpolate_property(parent, "position:y", parent.position.y, parent.position.y + (parent.position.y-self.position.y)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		parent.get_node("Tween").start()
		anim.play("break")
		yield(anim, "animation_finished")
		parent.call_deferred("queue_free")
		#body.call_deferred("queue_free")
		

func _on_lifetime_timeout():
	self.call_deferred("queue_free")
