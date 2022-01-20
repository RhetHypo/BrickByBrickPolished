extends Sprite

var laser = false
var water = false
var lava = false
var temp_speed = 0

func _ready():
	if water:
		modulate = Color(0,0,.75,1)
	elif lava:
		modulate = Color(1,0,0,1)

func change_color():
	if water:
		modulate = Color(0,0,.75,1)
	elif lava:
		modulate = Color(1,0,0,1)
	else:
		modulate = Color(0,0,0,1)