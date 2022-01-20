extends Sprite

const POWERUP = preload("res://scenes/entities/Powerup.tscn")

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize()

func brick_break(hit):
	var powtype = (randi() % 4) + 1
	if self.is_in_group("Powerup"):
		var powerup = POWERUP.instance()
		if powtype == 2 and !get_parent().paddle.isSticky:
			powerup.powerup_type = 2
			powerup.get_node("Sprite").modulate = Color(0,1,0,1)
		elif powtype == 3 and !get_parent().paddle.laser:
			powerup.powerup_type = 3
			powerup.get_node("Sprite").modulate = Color(0,1,1,1)
		elif powtype == 4 and !get_parent().paddle.water:
			powerup.powerup_type = 4
			powerup.get_node("Sprite").modulate = Color(0,0,1,1)
		else:
			powerup.powerup_type = 1
			powerup.get_node("Sprite").modulate = Color(1,1,1,1)
		powerup.position = self.position
		self.get_parent().add_child(powerup)
	get_parent().award_points(10)
	var anim = get_node("AnimationPlayer")
	get_node("Brick").call_deferred("queue_free")
	get_node("Tween").interpolate_property(self, "position:x", self.position.x, self.position.x + (self.position.x-hit.x)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_node("Tween").interpolate_property(self, "position:y", self.position.y, self.position.y + (self.position.y-hit.y)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_node("Tween").start()
	anim.play("break")
	yield(anim, "animation_finished")
	self.call_deferred("queue_free")
	