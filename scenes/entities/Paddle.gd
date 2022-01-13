extends KinematicBody2D

var started = false
var speed = 1500
var non_turbo = 1
var applied_turbo = non_turbo
var turbo = 2

const BALL = preload("res://scenes/entities/Ball.tscn")

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
		var newBall = BALL.instance()
		newBall.global_position = self.get_node("StartBall").global_position
		newBall.current_speed = get_parent().active_speed
		newBall.linear_velocity.y = -get_parent().active_speed
		self.get_node("StartBall").visible = false
		self.get_parent().add_child(newBall)

func newLife():
	started = false
	self.get_node("StartBall").visible = true

func upgrade(upgrade = 1):
	if upgrade == 1:
		print(1)
		for child in get_parent().get_children():
			if child.is_in_group("Ball"):
				var newBall = BALL.instance()
				newBall.global_position = child.global_position
				newBall.apply_central_impulse(Vector2(-500,0))
				child.apply_central_impulse(Vector2(500,0))
				self.get_parent().add_child(newBall)
	elif upgrade == 2:
		print(2)
	