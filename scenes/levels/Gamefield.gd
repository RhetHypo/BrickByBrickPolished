extends Node2D

var field_width = 32
var field_height = 32

var brick_width = 128
var brick_height = 64
var brick_offset = 10
var left_offset = 1024
var top_offset = 200

var generate_mode = 2
var def_area = Vector2(6,9) #first is RADIUS for row length
var def_bricks = globals.levels
var def_speed = 500
var active_speed = 500
var max_speed = 2000

export var points = 0
export var level = 1
export var lives = 3

export var decay = .7
export var max_offset = Vector2(50,25)
export var max_roll = 0.5

var shaking = 0.0
var transition = true
var shake_amount = 0.25
export var shapes = ["Grid", "RevTri", "CheckerSame", "Tri", "CheckerAlt"]
var upgradeable_bricks = []

const BRICK = preload("res://scenes/entities/Brick.tscn")
const PHANTOM = preload("res://scenes/entities/Phantom.tscn")

onready var life = get_node("Life")
onready var camera = get_node("Camera2D")
onready var deathAudio = get_node("deathPlayer")
onready var musicAudio = get_node("musicPlayer")
onready var paddle = get_node("Paddle")
onready var levelTransition = get_node("Camera2D/CanvasLayer/MarginContainer/LevelTransition")

var thread
var random = RandomNumberGenerator.new()

func _ready():
	if settings.music_enabled:
		musicAudio.volume_db = settings.music_level - 50
		musicAudio.play()
	if settings.control_scheme == 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	random.randomize()
	generate_bricks()
	update_points(points, points)
	update_level(level)
	update_lives(lives)
	update_speed_label(active_speed)
	settings.load_settings()
	init_settings()
	get_node("Transition").fade_in()
	yield(get_node("Transition/TransitionTween"), "tween_completed")
	get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer").visible = true
	yield(levelTransition, "transition_complete")
	transition = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause_game()

func _process(delta):
	if shaking > 0:
		shaking = max(shaking - decay * delta,0)
		shake(shaking)

func generate_bricks():
	var thread_error
	thread = Thread.new()
	if generate_mode == 1:
		#thread_error = thread.start(self, "generate_brick_area")
		generate_brick_area()
	elif generate_mode == 2:
		#thread_error = thread.start(self, "generate_brick_list", [(globals.levels[(level - 1) % len(globals.levels)]),(level-1)/len(globals.levels)])
		generate_brick_list([(globals.levels[(level - 1) % len(globals.levels)]),(level-1)/len(globals.levels)])
	elif generate_mode == 3:
		thread_error = thread.start(self, "generate_brick_shapes", (shapes[(level - 1) % len(shapes)]))
		#generate_brick_shapes((shapes[(level - 1) % len(shapes)]))
	if thread_error:
		print("Thread error!")
	
func add_shaking(amount):
    shaking = min(shaking + amount, 1.0)

func shake(shaking):
	var amount = pow(shaking, shake_amount)
	camera.rotation = max_roll * amount * rand_range(-1, 1)
	camera.offset.x = max_offset.x * amount * rand_range(-1, 1)
	camera.offset.y = max_offset.y * amount * rand_range(-1, 1)

func generate_brick_area(area = def_area):
	var newBrick
	var life = get_node("Life")
	for x in range(-area.x,area.x + 1):
		for y in range(0,area.y):
			newBrick = BRICK.instance()
			self.add_child_below_node(life,newBrick)
			newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
			newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	self.call_deferred("add_upgrades")

func generate_brick_list(params):
	var bricks = params[0]
	var durability_increase = params[1]
	print(durability_increase)
	for brick in bricks:
		var actual_dura = brick[0]
		if brick[0] != -1:
			actual_dura += durability_increase
		self.call_deferred("new_brick",brick[1],brick[2],actual_dura)
	self.call_deferred("add_upgrades")

func dropped_ball():
	if paddle.ballsInPlay == 1:
		award_lives(-1)
		add_shaking(.25)
	paddle.ballsInPlay -= 1

func award_lives(newLives):
	if paddle.isGold and newLives < 0:
		paddle.update_paddle(-1)
		for child in self.get_children():
			if child.is_in_group("Ball"):
				child.call_deferred("queue_free")
				#child.update_speed(active_speed)
			if child.is_in_group("Bullet"):
				child.call_deferred("queue_free")
			if child.is_in_group("Powerup"):
				child.call_deferred("queue_free")
			if child.is_in_group("Spark"):
				child.call_deferred("queue_free")
	else:
		lives += newLives
	if newLives < 0 and lives >= 0:
		update_lives(lives)
		if settings.sound_enabled:
			deathAudio.volume_db = settings.sound_level - 50
			deathAudio.play()
		paddle.newLife()
	elif lives < 0:
		transition = true
		globals.endgame = true
		globals.endgame_score = points
		globals.endgame_difficulty = settings.difficulty
		if settings.sound_enabled:
			deathAudio.volume_db = settings.sound_level - 50
			deathAudio.play()
			yield(deathAudio, "finished")
		get_node("Transition").switch_scene("res://scenes/menus/Highscores.tscn")
		#TODO: Actual game over screen

func level_check():
	var z: float = ( 1.0 )
	#quick and dirty spedometer
	for child in self.get_children():
		if child.is_in_group("Ball"):
			update_speed_label(child.linear_velocity.length())
	var complete = true
	for child in self.get_children():
		if child.is_in_group("Brick") and child.get_node_or_null("Brick") != null and child.durability != -1:
			complete = false
			break
	if complete and transition == false:
		level += 1
		update_level(level)
		levelTransition.next_level(level)
		for child in self.get_children():
			if child.is_in_group("Ball"):
				child.call_deferred("queue_free")
				#child.update_speed(active_speed)
			if child.is_in_group("Bullet"):
				child.call_deferred("queue_free")
			if child.is_in_group("Powerup"):
				child.call_deferred("queue_free")
			if child.is_in_group("Spark"):
				child.call_deferred("queue_free")
			if child.is_in_group("Brick"):
				child.call_deferred("queue_free")
		active_speed = def_speed + (level * def_speed/(15-settings.difficulty*2))
		if active_speed > max_speed:
			active_speed = max_speed
		for child in paddle.get_children():
			if child.is_in_group("Stuck"):
				child.call_deferred("queue_free")
		paddle.newLife()
		update_speed_label(active_speed)
		transition = true
		yield(levelTransition,"field_hidden")
		generate_bricks()
		yield(levelTransition,"transition_complete")
		transition = false
		update_lives()

func award_points(newPoints):
	points += newPoints
	update_points(points, newPoints)

func update_lives(newLives = lives):
	var lives = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Lives")
	lives.text = "Lives = " + str(newLives)
	if get_node("Paddle").isGold:
		lives.text += " + 1"
		lives.add_color_override("font_color", Color(1,1,0,1))
	else:
		lives.add_color_override("font_color", Color(0,0,0,1))

func update_points(points, newPoints):
	
	for i in range(points-newPoints, points):
		get_node("PointTimer").start()
		yield(get_node("PointTimer"), "timeout")
		get_node("PointTimer").stop()
		var display_points = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Score")
		display_points.text = "Points = " + str(i)
	
	var display_points = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Score")
	display_points.text = "Points = " + str(points)

func update_level(newLevel):
	var level = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Level")
	level.text = "Level = " + str(newLevel)

func update_speed_label(ball_speed):
	var speed_label = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Speed")
	speed_label.text = "Speed = " + str(stepify(ball_speed/def_speed,0.1)) + "x"

func _on_CompleteCheck_timeout():
	level_check()

func pause_game():
	get_node("Camera2D/CanvasLayer/PauseDialog").popup_centered()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_PauseDialog_popup_hide():
	get_tree().paused = false
	if settings.control_scheme == 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func init_settings():
	get_node("Camera2D/CanvasLayer/PauseDialog/MarginContainer/VBoxContainer/DifficultyOptions").visible = false

func generate_brick_shapes(shape, area = def_area):
	#Solid brick: Enough said
	#Rings: Skip only odds/evens
	#Axis: Only show when one coord is zero, or both are equal
	#Triangles: Two triangles, horizontal or vertical, in or out.
	#Checkerboard: Alternating
	if shape == "Solid":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				self.call_deferred("new_brick",x,y)
				#new_brick(x,y)
	if shape == "Rings":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if y % 2 == 0 || x == -area.x || x == area.x || y == abs(x):
					self.call_deferred("new_brick",x,y)
					#new_brick(x,y)
	if shape == "Grid":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if y % 2 == 0 || x % 2 == 0:
					self.call_deferred("new_brick",x,y)
					#new_brick(x,y)
	if shape == "CheckerAlt":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (y % 2 == 0 and x % 2 != 0) or (y % 2 != 0 and x % 2 == 0):
					self.call_deferred("new_brick",x,y)
					#new_brick(x,y)
	if shape == "CheckerSame":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (y % 2 != 0 and x % 2 != 0) or (y % 2 == 0 and x % 2 == 0):
					self.call_deferred("new_brick",x,y)
					#new_brick(x,y)
	if shape == "Tri":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (y > abs(x) + 1):
					self.call_deferred("new_brick",x,y)
					#new_brick(x,y)
	if shape == "RevTri":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (abs(x) > y) || abs(x) > (area.y - (y+1)):
					self.call_deferred("new_brick",x,y)
					#new_brick(x,y)
	self.call_deferred("add_upgrades")

func new_brick(x, y, durability):
	var newBrick = PHANTOM.instance()
	newBrick.get_node("Brick/Label").text = str(x) + ", " + str(y)
	newBrick.coords = Vector2(x,y)
	newBrick.durability = durability
	upgradeable_bricks.append(newBrick)
	self.add_child_below_node(life,newBrick)
	newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
	newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	#newBrick.get_node("AnimationPlayer").play("create")
	#yield(newBrick.get_node("AnimationPlayer"),"animation_finished")

func add_upgrades():
	var total_upgrades = (4 - settings.difficulty) * 2
	for i in range(0,total_upgrades):
		if upgradeable_bricks.size() == 0:
			break
		var select_brick = rand_range(0,upgradeable_bricks.size())
		upgradeable_bricks[select_brick].add_to_group("PowerupBrick")
	upgradeable_bricks.clear()

func _on_Life_body_exited(body):
	pass # Replace with function body.
