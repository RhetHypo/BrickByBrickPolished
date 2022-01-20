extends Control

onready var panel = get_node("Panel")
onready var tween = get_node("Tween")
onready var label = get_node("Label")

signal field_hidden
signal transition_complete

var start_position

func _ready():
	next_level(1)
	
func next_level(level):
	next_level_start(level)
	yield(self, "field_hidden")
	next_level_end()

func next_level_start(level):
	self.visible = true	
	get_node("Label").text = "LEVEL " + str(level)
	tween.interpolate_property(panel, "modulate:a", 0, 1, .2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	emit_signal("field_hidden")

func next_level_end():
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
	emit_signal("transition_complete")