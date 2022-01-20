extends RigidBody2D

var x_speed = 0
var y_speed = 0
var current_speed = 500
var max_temp_speed = 2000
var paddle_width = 512
var temp_alive = false
var just_released = true

var angle_cap = 0.75
var combo = 0

#these need to persist between bounces
var laser = false
var can_fire = true
var temp_speed = 0

onready var breakAudio = get_node("breakPlayer")
onready var paddleAudio = get_node("paddlePlayer")
onready var wallAudio = get_node("wallPlayer")
onready var blaster = get_node("BlasterPivot")
onready var fireTimer = get_node("fireTimer")

const BULLET = preload("res://scenes/entities/Bullet.tscn")

func _ready():
	if laser:
		unlock_laser()

func _physics_process(delta):
	blaster.rotation_degrees += delta * 360

func _integrate_forces(state):
	if state.linear_velocity.length()!=current_speed+temp_speed:
		state.linear_velocity=state.linear_velocity.normalized()*(current_speed+temp_speed)
	if pow(state.linear_velocity.x,2) > pow(current_speed+temp_speed,2) * 0.75:
		if state.linear_velocity.x < 0:
			state.linear_velocity.x = -sqrt(pow(current_speed+temp_speed,2) * 0.75)
		else:
			state.linear_velocity.x = sqrt(pow(current_speed+temp_speed,2) * 0.75)
		if state.linear_velocity.y < 0:
			state.linear_velocity.y = -sqrt(pow(current_speed+temp_speed,2) * 0.25)
		else:
			state.linear_velocity.y = sqrt(pow(current_speed+temp_speed,2) * 0.25)

func _on_Ball_body_entered(body):
	if body.is_in_group("Paddle"):
		if settings.sound_enabled:
			paddleAudio.volume_db = settings.sound_level - 50
			paddleAudio.pitch_scale = rand_range(0.90,1.1)
			paddleAudio.play()
			combo = 0
		if body.isSticky:
			self.temp_alive = true
			body.newBall(self)
			self.call_deferred("queue_free")
		self.apply_central_impulse(Vector2(current_speed * 2 * (self.position.x - body.position.x)/paddle_width,0))
	elif body.is_in_group("Brick"):
		if settings.sound_enabled:
			breakAudio.volume_db = settings.sound_level - 50
			breakAudio.pitch_scale = 1.5 + combo
			combo += .10
			if combo >= 5:
				combo = 5
			breakAudio.play()
		temp_speed += ((settings.difficulty+1)*5)
		if temp_speed > max_temp_speed:
			temp_speed = max_temp_speed
		body.get_parent().brick_break(self.position)
#		var parent = body.get_parent()
#		var anim = parent.get_node("AnimationPlayer")
#		body.call_deferred("queue_free")
#		parent.get_node("Tween").interpolate_property(parent, "position:x", parent.position.x, parent.position.x + (parent.position.x-self.position.x)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		parent.get_node("Tween").interpolate_property(parent, "position:y", parent.position.y, parent.position.y + (parent.position.y-self.position.y)*10, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#		parent.get_node("Tween").start()
#		anim.play("break")
#		yield(anim, "animation_finished")
#		parent.call_deferred("queue_free")
	else:
		if settings.sound_enabled:
			wallAudio.volume_db = settings.sound_level - 50
			wallAudio.pitch_scale = rand_range(1.5,3.0)
			wallAudio.play()

func unlock_laser():
	laser = true
	blaster.visible = true

func blast():
	if just_released:
		just_released = false
		return
	elif laser and can_fire == true:
		can_fire = false
		fireTimer.start()
		var newBullet = BULLET.instance()
		get_parent().add_child(newBullet)
		newBullet.global_position = blaster.get_node("Blaster/SpawnPoint").global_position
		var angle = blaster.rotation_degrees
		newBullet.rotation_degrees = angle
		newBullet.origin = self
		newBullet.apply_central_impulse(Vector2(cos(deg2rad(angle)), sin(deg2rad(angle))) * 2000)
		return

func death():
	#TODO: Add check for if this is the last ball in play, if adding multiple balls
	get_parent().dropped_ball()
	#get_parent().award_lives(-1)
	#get_parent().add_shaking(.25)
	self.call_deferred("queue_free")

func update_speed(speed):
	current_speed = speed

func _on_fireTimer_timeout():
	can_fire = true
