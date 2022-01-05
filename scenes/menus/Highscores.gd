extends Control

var scores_file = "user://hiscores.save"
var scores = []

const NAME = preload("res://scenes/menus/CustomName.tscn")
const SCORE = preload("res://scenes/menus/CustomScore.tscn")

onready var grid = get_node("VBoxContainer/GridContainer")

func _ready():
	load_scores()
	display_scores()

func display_scores():
	var index = 0
	for score in scores:
		index += 1
		var newIndex = NAME.instance()
		newIndex.text = str(index)
		grid.add_child(newIndex)
		var newName = NAME.instance()
		newName.text = score[0]
		grid.add_child(newName)
		var newScore = SCORE.instance()
		newScore.text = score[1]
		grid.add_child(newScore)
		var newspacer = NAME.instance()
		newspacer.text = ""
		grid.add_child(newspacer)

func load_scores():
	var getFile = File.new()
	if getFile.file_exists(scores_file):
		getFile.open(scores_file, File.READ)
		scores = getFile.get_var()
		getFile.close()
	if len(scores) < 10:
		for i in range(len(scores),10):
			scores.append(["AAA", "0"])
	#should load existing scores, and fill in nonexisting ones if there are less than ten

func save_score():
	pass
	#should 
	#1. get current scores, 
	#2. find if the new one is a high score, 
	#3. prompt for name to enter(three characters for now),
	#4. place at proper point in list by removing the last item, and inserting in last spot
