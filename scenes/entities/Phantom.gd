extends Sprite

var coords = Vector2(0,0)

const POWERUP = preload("res://scenes/entities/Powerup.tscn")

var random = RandomNumberGenerator.new()
export var durability = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize()
	update_color()

func brick_break(hit):
	#some weighted random shenanigans
	if durability >= 1:
		durability -= 1
		update_color()
	elif durability == 0:
		if self.is_in_group("Powerup"):
			var powtype = 1
			if settings.difficulty == 1:
				powtype = random.randi_range(1,7)
			else:
				powtype = random.randi_range(1,6)
			if powtype <= 3:
				powtype = random.randi_range(2,4)
			elif powtype > 3 and powtype <= 6:
				powtype = random.randi_range(5,8)
			else:
				powtype = 1
			#TEMP
			powtype = 1
			var powerup = POWERUP.instance()
			if powtype == 2 and !get_parent().paddle.laser:
				powerup.powerup_type = 2
				powerup.get_node("Sprite").modulate = Color(0,1,1,1)
			elif powtype == 3 and !get_parent().paddle.water:
				powerup.powerup_type = 3
				powerup.get_node("Sprite").modulate = Color(0,0,1,1)
			elif powtype == 4 and !get_parent().paddle.lava:
				powerup.powerup_type = 4
				powerup.get_node("Sprite").modulate = Color(1,0,0,1)
			elif powtype == 5 and !get_parent().paddle.isSticky:
				powerup.powerup_type = 5
				powerup.get_node("Sprite").modulate = Color(0,1,0,1)
			elif powtype == 6 and !get_parent().paddle.isNeo:
				powerup.powerup_type = 6
				powerup.get_node("Sprite").modulate = Color(1,1,1,1)
			elif powtype == 7 and !get_parent().paddle.isSilver:
				powerup.powerup_type = 7
				powerup.get_node("Sprite").modulate = Color(.7,.7,.7,1)
			elif powtype == 8 and !get_parent().paddle.isGold:
				powerup.powerup_type = 8
				powerup.get_node("Sprite").modulate = Color(1,1,0,1)
			else:
				powerup.powerup_type = 1
				powerup.get_node("Sprite").modulate = Color(0,0,0,1)
			powerup.position = self.position
			self.get_parent().add_child(powerup)
		get_parent().award_points(10)
		var anim = get_node("AnimationPlayer")
		get_node("Brick").call_deferred("queue_free")
		get_node("Tween").interpolate_property(self, "position:x", self.position.x, self.position.x + (self.position.x-hit.x)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(self, "position:y", self.position.y, self.position.y + (self.position.y-hit.y)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(self, "rotation_degrees", 0, 720, .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(self, "scale", 1, 2, .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		get_node("Tween").interpolate_property(self, "modulate:a", 1, 0, .5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		get_node("Tween").start()
		yield(get_node("Tween"),"tween_completed")
		#anim.play("break")
		#yield(anim, "animation_finished")
		self.call_deferred("queue_free")

func update_color():
	if durability == -1:
		self.modulate = settings.color_defs["BLACK"]
	else:
		self.modulate = settings.color_defs[settings.color_queue[durability]]