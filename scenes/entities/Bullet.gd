extends RigidBody2D

var origin = null

onready var breakAudio = get_node("breakPlayer")
onready var fireAudio = get_node("firePlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	if settings.sound_enabled:
		fireAudio.volume_db = settings.sound_level - 50
		fireAudio.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_Bullet_body_entered(body):
	if body.is_in_group("Brick"):
		body.get_parent().brick_break(self.position)
		if settings.sound_enabled and is_instance_valid(origin) and "breakAudio" in origin:
			origin.breakAudio.volume_db = settings.sound_level - 50
			origin.breakAudio.play()
			self.call_deferred("queue_free")
		else:
			self.call_deferred("queue_free")
	else:
		self.call_deferred("queue_free")

func _on_lifetime_timeout():
	self.call_deferred("queue_free")
