extends RigidBody2D

var x_speed = 0
var y_speed = 0
var current_speed = 500
var paddle_width = 512

func _ready():
	pass

func _physics_process(delta):
	pass

func _integrate_forces(state):
	if state.linear_velocity.length()!=current_speed:
        state.linear_velocity=state.linear_velocity.normalized()*current_speed

func _on_Ball_body_entered(body):
	if body.is_in_group("Paddle"):
		self.apply_central_impulse(Vector2(current_speed * 2 * (self.position.x - body.position.x)/paddle_width,0))
	elif body.is_in_group("Brick"):
		get_parent().award_points(10)
		body.queue_free()

func death():
	#TODO: Add check for if this is the last ball in play, if adding multiple balls
	get_parent().award_lives(-1)
	self.queue_free()