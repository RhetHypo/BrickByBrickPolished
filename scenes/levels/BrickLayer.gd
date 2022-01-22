extends Node2D

export var grid = Vector2(6,9)

var brick_width = 128
var brick_height = 64
var brick_offset = 10
var left_offset = 1024
var top_offset = 200
var selected = 0

const PHANTOM = preload("res://scenes/entities/Phantom.tscn")
const BRICK_SELECT = preload("res://scenes/menus/BrickSelector.tscn")

onready var bricks = get_node("Grid")
onready var brick_selector = get_node("Camera2D/CanvasLayer/Control/ScrollContainer/HBoxContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_brick_grid()
	fill_brick_selector()

func _process(delta):
	if Input.is_action_pressed("right_click"):
		var mouse_pos = get_global_mouse_position()
		for brick in bricks.get_children():
			if(abs(mouse_pos.x - brick.global_position.x) < 64 && abs(mouse_pos.y - brick.global_position.y) < 32):
				brick.modulate.a = 0
	elif Input.is_action_pressed("click"):
		var mouse_pos = get_global_mouse_position()
		for brick in bricks.get_children():
			if(abs(mouse_pos.x - brick.global_position.x) < 64 && abs(mouse_pos.y - brick.global_position.y) < 32):
				brick.modulate.a = 1
				brick.durability = selected
				brick.update_color()
#				if selected >= 0:
#					#brick.modulate = settings.color_defs[settings.color_queue[selected]]
#
#				else:
#					brick.durability = selected#TODO: Sort out this logic
#					brick.modulate = settings.color_defs["BLACK"]

func generate_brick_grid():
	for x in range(-grid.x,grid.x + 1):
		for y in range(0,grid.y):
			self.call_deferred("new_brick",x,y)
			#new_brick(x,y)

func new_brick(x, y):
	var newBrick = PHANTOM.instance()
	newBrick.get_node("Brick/Label").text = str(x) + ", " + str(y)
	newBrick.coords = Vector2(x,y)
	bricks.add_child(newBrick)
	newBrick.global_position.x = x * (brick_width + brick_offset) + left_offset
	newBrick.global_position.y = y * (brick_height + brick_offset) + top_offset
	newBrick.get_node("AnimationPlayer").play("create")
	yield(newBrick.get_node("AnimationPlayer"),"animation_finished")

func fill_brick_selector():
	var newBrickSelect = BRICK_SELECT.instance()
	newBrickSelect.modulate = settings.color_defs["BLACK"]
	newBrickSelect.connect("pressed", self, "select_brick", [-1])
	brick_selector.add_child(newBrickSelect)
	var index = 0
	for color in settings.color_queue:
		newBrickSelect = BRICK_SELECT.instance()
		newBrickSelect.modulate = settings.color_defs[color]
		newBrickSelect.connect("pressed", self, "select_brick", [index])
		brick_selector.add_child(newBrickSelect)
		index += 1
		
func select_brick(new_selected):
	selected = new_selected

func _on_ExportButton_pressed():
	var return_data = []
	for brick in bricks.get_children():
		if brick.modulate.a == 1:
			return_data.append([brick.durability, brick.coords.x, brick.coords.y])
	print(return_data)