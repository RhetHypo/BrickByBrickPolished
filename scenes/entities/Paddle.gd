extends KinematicBody2D

var started = false
var speed = 1500
var non_turbo = 1
var applied_turbo = non_turbo
var turbo = 2
var ballsInPlay = 0
var isSticky = true
var paddle_width = 512 #idk

const BALL = preload("res://scenes/entities/Ball.tscn")
const STARTBALL = preload("res://scenes/entities/StartBall.tscn")

func _ready():
	pass

func _process(delta):
	#var pos = 0
	if settings.control_scheme == 0:
		if Input.is_action_just_pressed("click"):
			self.start()
		#mouse
		#pos = get_global_mouse_position().x
		self.position.x = get_global_mouse_position().x
	elif settings.control_scheme == 1:
		#wasd
		if Input.is_action_pressed("S"):
			applied_turbo = turbo
		else:
			applied_turbo = non_turbo
		if Input.is_action_pressed("A"):
			self.position.x -= speed * applied_turbo * delta
		elif Input.is_action_pressed("D"):
			self.position.x += speed * applied_turbo * delta
		if Input.is_action_just_pressed("W"):
			self.start()
	elif settings.control_scheme == 2:
		#arrows
		if Input.is_action_pressed("ui_down"):
			applied_turbo = turbo
		else:
			applied_turbo = non_turbo
		if Input.is_action_pressed("ui_left"):
			self.position.x -= speed * applied_turbo * delta
		elif Input.is_action_pressed("ui_right"):
			self.position.x += speed * applied_turbo * delta
		if Input.is_action_just_pressed("ui_up"):
			self.start()
	if(self.position.x <= 275):
		self.position.x = 275
	if(self.position.x >= 1760):
		self.position.x = 1760
	if Input.is_action_just_pressed("upgrade_test"):
		self.upgrade(1)

func start():
	if !started:
		started = true
		ballsInPlay = 1
	for child in self.get_children():
		if child.is_in_group("Stuck"):
			var newBall = BALL.instance()
			newBall.global_position = child.global_position
			newBall.current_speed = get_parent().active_speed
			newBall.linear_velocity.y = -get_parent().active_speed
			newBall.laser = true
			newBall.temp_speed = child.temp_speed
			newBall.apply_central_impulse(Vector2(get_parent().active_speed * 2 * (newBall.position.x - self.position.x)/paddle_width,0))
			child.call_deferred("queue_free")
			self.get_parent().add_child(newBall)
	for child in get_parent().get_children():
		if child.is_in_group("Ball"):
			child.blast()

func newLife():
	started = false
	#self.get_node("StartBall").visible = true
	var newBall = STARTBALL.instance()
	newBall.position = Vector2(0,-64)
	self.add_child(newBall)
	ballsInPlay = 0

func newBall(ball):
	var newBall = STARTBALL.instance()
	newBall.position.x = ball.global_position.x - self.global_position.x
	newBall.position.y = -64
	newBall.laser = ball.laser
	newBall.temp_speed = ball.temp_speed
	self.add_child(newBall)

func upgrade(upgrade = 1):
	if upgrade == 1:
		for child in get_parent().get_children():
			if child.is_in_group("Ball"):
				var newBall = BALL.instance()
				newBall.laser = child.laser
				newBall.global_position = child.global_position
				newBall.current_speed = child.current_speed
				newBall.temp_speed = child.temp_speed
				newBall.apply_central_impulse(Vector2(-500,child.linear_velocity.y))
				child.apply_central_impulse(Vector2(500,0))
				self.get_parent().add_child(newBall)
				ballsInPlay += 1
		for child in get_children():
			if child.is_in_group("Stuck"):
				var newBall = STARTBALL.instance()
				newBall.laser = child.laser
				newBall.temp_speed = child.temp_speed
				newBall.position.x = child.position.x - 20
				newBall.position.y = child.position.y
				child.position.x += 20
				self.add_child(newBall)
				ballsInPlay += 1
	elif upgrade == 2:
		print(2)
		self.isSticky = true
	elif upgrade == 3:
		print(3)
		for child in get_parent().get_children():
			if child.is_in_group("Ball"):
				child.laser = true
	