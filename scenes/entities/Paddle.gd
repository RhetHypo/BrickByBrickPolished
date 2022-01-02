extends KinematicBody2D

var started = false

const BALL = preload("res://scenes/entities/Ball.tscn")

func _ready():
	pass

func _process(delta):
	var pos = get_global_mouse_position().x
	self.position.x = get_global_mouse_position().x
	if(pos <= 275):
		self.position.x = 275
	if(pos >= 1760):
		self.position.x = 1760
	if Input.is_action_just_pressed("click"):
		self.start()

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
	