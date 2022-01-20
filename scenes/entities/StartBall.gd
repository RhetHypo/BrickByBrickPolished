extends Sprite

var laser = false
var water = false
var temp_speed = 0

func _ready():
	if water:
		modulate = Color(0,0,.75,1)

func change_color():
	if laser:
		modulate = Color(0,0,0,1)
	elif water:
		modulate = Color(0,0,.75,1)