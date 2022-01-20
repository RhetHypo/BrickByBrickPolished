extends KinematicBody2D

var started = false
var speed = 1500
var non_turbo = 1
var applied_turbo = non_turbo
var turbo = 2
var ballsInPlay = 0
var isSticky = false
var laser = false
var water = false
var lava = false
var slow_motion = true
var paddle_width = 512 #idk

onready var upgrade1Audio = get_node("upgrade1Player")
onready var upgrade2Audio = get_node("upgrade2Player")
onready var upgrade3Audio = get_node("upgrade3Player")
onready var startAudio = get_node("startPlayer")
onready var stuckAudio = get_node("stuckPlayer")
onready var unstuckAudio = get_node("unstuckPlayer")

const BALL = preload("res://scenes/entities/Ball.tscn")
const STARTBALL = preload("res://scenes/entities/StartBall.tscn")

var get_color

func _ready():
	get_color = self.get_node("Sprite").modulate

func _process(delta):
	#var pos = 0
	if get_parent().transition == false:
		if settings.control_scheme == 0:
			if Input.is_action_pressed("click"):
				self.take_action()
			else:
				self.take_inaction()
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
			if Input.is_action_pressed("W"):
				self.take_action()
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
			if Input.is_action_pressed("ui_up"):
				self.take_action()
		if(self.position.x <= 275):
			self.position.x = 275
		if(self.position.x >= 1760):
			self.position.x = 1760
		#if Input.is_action_just_pressed("upgrade_test"):
		#	self.upgrade(1)

func take_action():
	if !started:
		started = true
		ballsInPlay = 1
		if settings.sound_enabled:
			startAudio.volume_db = settings.sound_level - 50
			startAudio.play()
	for child in self.get_children():
		if child.is_in_group("Stuck"):
			var newBall = BALL.instance()
			newBall.global_position = child.global_position
			newBall.current_speed = get_parent().active_speed
			newBall.linear_velocity.y = -get_parent().active_speed
			newBall.laser = child.laser
			newBall.water = child.water
			newBall.lava = child.lava
			newBall.temp_speed = child.temp_speed
			newBall.apply_central_impulse(Vector2(get_parent().active_speed * 2 * (newBall.position.x - self.position.x)/paddle_width,0))
			child.call_deferred("queue_free")
			self.get_parent().add_child(newBall)
			if settings.sound_enabled:
				unstuckAudio.volume_db = settings.sound_level - 50
				unstuckAudio.play()
	for child in get_parent().get_children():
		if child.is_in_group("Ball"):
			child.blast()
	if slow_motion:
		Engine.time_scale = 0.3

func take_inaction():
	Engine.time_scale = 1

func newLife():
	started = false
	#self.get_node("StartBall").visible = true
	var newBall = STARTBALL.instance()
	newBall.position = Vector2(0,-64)
	self.add_child(newBall)
	ballsInPlay = 0
	self.isSticky = false
	self.laser = false
	self.get_node("Sprite").modulate = get_color

func newBall(ball):
	if settings.sound_enabled:
		stuckAudio.volume_db = settings.sound_level - 50
		stuckAudio.play()
	var newBall = STARTBALL.instance()
	newBall.position.x = ball.global_position.x - self.global_position.x
	newBall.position.y = -64
	newBall.laser = ball.laser
	newBall.water = ball.water
	newBall.lava = ball.lava
	newBall.temp_speed = ball.temp_speed
	self.add_child(newBall)

func upgrade(upgrade = 1):
	if upgrade == 1:
		if settings.sound_enabled:
			upgrade1Audio.volume_db = settings.sound_level - 50
			upgrade1Audio.play()
		for child in get_parent().get_children():
			if child.is_in_group("Ball"):
				var newBall = BALL.instance()
				newBall.laser = child.laser
				newBall.water = child.water
				newBall.lava = child.lava
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
				newBall.water = child.water
				newBall.lava = child.lava
				newBall.temp_speed = child.temp_speed
				newBall.position.x = child.position.x - 20
				newBall.position.y = child.position.y
				child.position.x += 20
				self.add_child(newBall)
				ballsInPlay += 1
	elif upgrade == 2:
		if settings.sound_enabled:
			upgrade2Audio.volume_db = settings.sound_level - 50
			upgrade2Audio.play()
		self.isSticky = true
		self.get_node("Sprite").modulate = Color(0,1,0,1)
	elif upgrade == 3: #laser
		update_balls(1)
	elif upgrade == 4: #water
		update_balls(2)
	elif upgrade == 5: #lava
		update_balls(3)
	elif upgrade == 6: #sniper
		pass#TODO: implement sniper
	elif upgrade == 7: #neopolitan
		pass#TODO: implement neopolitan
	elif upgrade == 8: #silver
		pass#TODO: implement silver
	elif upgrade == 9: #golden
		pass#TODO: implement golden

func update_balls(update_value):
	if update_value == 1:#laser
		self.laser = true
		self.water = false
		self.lava = false
	elif update_value == 2:#water
		self.laser = false
		self.water = true
		self.lava = false
	elif update_value == 3:#lava
		self.laser = false
		self.water = false
		self.lava = true
	if settings.sound_enabled:
		upgrade3Audio.volume_db = settings.sound_level - 50
		upgrade3Audio.play()
	for child in get_parent().get_children():
		if child.is_in_group("Ball"):
			child.set_type(update_value)
	for child in get_children():
		if child.is_in_group("Stuck"):
			child.laser = self.laser
			child.water = self.water
			child.lava = self.lava
			child.change_color()
	