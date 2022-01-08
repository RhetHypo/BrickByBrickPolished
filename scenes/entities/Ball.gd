extends RigidBody2D

var x_speed = 0
var y_speed = 0
var current_speed = 500
var temp_speed = 0
var max_temp_speed = 2000
var paddle_width = 512

var angle_cap = 0.75

func _ready():
	pass

func _physics_process(delta):
	pass

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
		self.apply_central_impulse(Vector2(current_speed * 2 * (self.position.x - body.position.x)/paddle_width,0))
	elif body.is_in_group("Brick"):
		get_parent().award_points(10)
		print("TEMP: ", (settings.difficulty+1)*2)
		temp_speed += ((settings.difficulty+1)*2)
		if temp_speed > max_temp_speed:
			temp_speed = max_temp_speed
		body.queue_free()

func death():
	#TODO: Add check for if this is the last ball in play, if adding multiple balls
	get_parent().award_lives(-1)
	get_parent().add_shaking(.25)
	self.queue_free()

func update_speed(speed):
	current_speed = speed