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
		body.get_parent().brick_break(self.position)

func _on_lifetime_timeout():
	self.call_deferred("queue_free")
