extends Control

onready var panel = get_node("Panel")
onready var tween = get_node("Tween")
onready var label = get_node("Label")

var start_position

func _ready():
	next_level(1)

func next_level(level):
	self.visible = true	
	get_node("Label").text = "LEVEL " + str(level)
	tween.interpolate_property(panel, "modulate:a", 0, 1, .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	label.visible = true
	tween.interpolate_property(label, "rect_position:x", -500, 0, 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	yield(tween,"tween_completed")
	tween.interpolate_property(label, "rect_position:x", 0, 2000, 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.start()
	yield(tween,"tween_completed")
	tween.interpolate_property(panel, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	label.visible = false
	self.visible = false