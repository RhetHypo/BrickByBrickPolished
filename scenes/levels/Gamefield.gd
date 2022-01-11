extends Node2D

var field_width = 32
var field_height = 32

var brick_width = 128
var brick_height = 64
var brick_offset = 10
var left_offset = 1024
var top_offset = 200

var generate_mode = 3
var def_area = Vector2(6,9) #first is RADIUS for row length
var def_bricks = [Vector2(1,1),Vector2(1,2),Vector2(2,2),Vector2(2,1)]
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
var shake_amount = 0.25
export var shapes = ["Grid", "RevTri", "CheckerSame", "Tri", "CheckerAlt"]

const BRICK = preload("res://scenes/entities/Brick.tscn")
const PHANTOM = preload("res://scenes/entities/Phantom.tscn")

onready var life = get_node("Life")
onready var camera = get_node("Camera2D")
onready var deathAudio = get_node("deathPlayer")
onready var musicAudio = get_node("musicPlayer")

func _ready():
	if settings.music_enabled:
		musicAudio.volume_db = settings.music_level - 50
		musicAudio.play()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	generate_bricks()
	update_points(points, points)
	update_level(level)
	update_lives(lives)
	settings.load_settings()
	init_settings()
	get_node("Transition").fade_in()
	yield(get_node("Transition/TransitionTween"), "tween_completed")
	get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer").visible = true

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause_game()

func _process(delta):
	if shaking > 0:
		shaking = max(shaking - decay * delta,0)
		shake(shaking)

func generate_bricks():
	if generate_mode == 1:
		generate_brick_area()
	elif generate_mode == 2:
		generate_brick_list()
	elif generate_mode == 3:
		generate_brick_shapes(shapes[(level - 1) % len(shapes)])

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

func generate_brick_list(bricks = def_bricks):
	var newBrick
	for brick in bricks:
		newBrick = BRICK.instance()
		self.add_child(newBrick)
		newBrick.global_position = brick

func award_lives(newLives):
	lives += newLives
	update_lives(lives)
	if newLives < 0 and lives >= 1:
		if settings.sound_enabled:
			deathAudio.volume_db = settings.sound_level - 50
			deathAudio.play()
		get_node("Paddle").newLife()
	elif lives <= 0:
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
	#quick and dirty spedometer
	for child in self.get_children():
		if child.is_in_group("Ball"):
			update_speed_label(child.linear_velocity.length())
	var complete = true
	for child in self.get_children():
		if child.is_in_group("Brick"):
			complete = false
	if complete:
		level += 1
		update_level(level)
		generate_bricks()
		for child in self.get_children():
			if child.is_in_group("Ball"):
				active_speed = def_speed + (level * def_speed/(15-settings.difficulty*4))
				if active_speed > max_speed:
					active_speed = max_speed
				child.update_speed(active_speed)
		#TODO: Make this more dynamic, and progress through levels

func award_points(newPoints):
	points += newPoints
	update_points(points, newPoints)

func update_lives(newLives):
	var lives = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Lives")
	lives.text = "Lives: " + str(newLives)

func update_points(points, newPoints):
	
	for i in range(points-newPoints, points):
		get_node("PointTimer").start()
		yield(get_node("PointTimer"), "timeout")
		get_node("PointTimer").stop()
		var display_points = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Score")
		display_points.text = "Points: " + str(i)
	
	var display_points = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Score")
	display_points.text = "Points: " + str(points)

func update_level(newLevel):
	var level = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Level")
	level.text = "Level " + str(newLevel)

func update_speed_label(ball_speed):
	var speed_label = get_node("Camera2D/CanvasLayer/MarginContainer/VBoxContainer/HBoxContainer/Speed")
	speed_label.text = "Speed: " + str(ball_speed)

func _on_CompleteCheck_timeout():
	level_check()

func pause_game():
	get_node("Camera2D/CanvasLayer/PauseDialog").popup_centered()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_PauseDialog_popup_hide():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func init_settings():
	get_node("Camera2D/CanvasLayer/PauseDialog/MarginContainer/VBoxContainer/DifficultyOptions").visible = false

func generate_brick_shapes(shape, area = def_area):
	var newBrick
	
	#Solid brick: Enough said
	#Rings: Skip only odds/evens
	#Axis: Only show when one coord is zero, or both are equal
	#Triangles: Two triangles, horizontal or vertical, in or out.
	#Checkerboard: Alternating
	if shape == "Solid":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				newBrick = BRICK.instance()
				newBrick.get_node("Label").text = str(x) + ", " + str(y)
				self.add_child_below_node(life,newBrick)
				newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
				newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	if shape == "Rings":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if y % 2 == 0 || x == -area.x || x == area.x || y == abs(x):
					newBrick = BRICK.instance()
					newBrick.get_node("Label").text = str(x) + ", " + str(y)
					self.add_child_below_node(life,newBrick)
					newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
					newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	if shape == "Grid":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if y % 2 == 0 || x % 2 == 0:
					newBrick = new_brick(x,y)
					#self.add_child_below_node(life,newBrick)
#					newBrick = BRICK.instance()
#					newBrick.get_node("Label").text = str(x) + ", " + str(y)
#					self.add_child_below_node(life,newBrick)
#					newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
#					newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	if shape == "CheckerAlt":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (y % 2 == 0 and x % 2 != 0) or (y % 2 != 0 and x % 2 == 0):
					newBrick = BRICK.instance()
					newBrick.get_node("Label").text = str(x) + ", " + str(y)
					self.add_child_below_node(life,newBrick)
					newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
					newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	if shape == "CheckerSame":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (y % 2 != 0 and x % 2 != 0) or (y % 2 == 0 and x % 2 == 0):
					newBrick = BRICK.instance()
					newBrick.get_node("Label").text = str(x) + ", " + str(y)
					self.add_child_below_node(life,newBrick)
					newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
					newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	if shape == "Tri":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (y > abs(x) + 1):
					newBrick = BRICK.instance()
					newBrick.get_node("Label").text = str(x) + ", " + str(y)
					self.add_child_below_node(life,newBrick)
					newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
					newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	if shape == "RevTri":
		for x in range(-area.x,area.x + 1):
			for y in range(0,area.y):
				if (abs(x) > y) || abs(x) > (area.y - (y+1)):
					new_brick(x,y)
					

func new_brick(x, y):
	var newBrick = PHANTOM.instance()
	newBrick.get_node("Brick/Label").text = str(x) + ", " + str(y)
	newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
	newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	self.add_child_below_node(life,newBrick)
	newBrick.get_node("AnimationPlayer").play("create")
	yield(newBrick.get_node("AnimationPlayer"),"animation_finished")

func _on_Life_body_exited(body):
	pass # Replace with function body.
