extends Node2D

var field_width = 32
var field_height = 32

var brick_width = 128
var brick_height = 64
var brick_offset = 0
var left_offset = 1024
var top_offset = 200

var generate_mode = 1
var def_area = Vector2(6,7) #first is RADIUS for row length
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

const BRICK = preload("res://scenes/entities/Brick.tscn")

onready var camera = get_node("Camera2D")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if generate_mode == 1:
		generate_brick_area()
	elif generate_mode == 2:
		generate_brick_list()
	update_points(points, points)
	update_level(level)
	update_lives(lives)
	settings.load_settings()
	init_settings()

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		pause_game()

func _process(delta):
	if shaking > 0:
		shaking = max(shaking - decay * delta,0)
		shake(shaking)

func add_shaking(amount):
    shaking = min(shaking + amount, 1.0)

func shake(shaking):
	var amount = pow(shaking, shake_amount)
	camera.rotation = max_roll * amount * rand_range(-1, 1)
	camera.offset.x = max_offset.x * amount * rand_range(-1, 1)
	camera.offset.y = max_offset.y * amount * rand_range(-1, 1)

func generate_brick_area(area = def_area):
	var newBrick
	for x in range(-area.x,area.x + 1):
		for y in range(0,area.y):
			newBrick = BRICK.instance()
			self.add_child(newBrick)
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
		get_node("Paddle").newLife()
	elif lives <= 0:
		print("Game Over")
		#TODO: Actual game over screen

func level_check():
	var complete = true
	for child in self.get_children():
		if child.is_in_group("Brick"):
			complete = false
	if complete:
		level += 1
		update_level(level)
		generate_brick_area()
		for child in self.get_children():
			if child.is_in_group("Ball"):
				active_speed = def_speed + (level * def_speed/10)
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

