extends Node2D

@export var ColourMode : String = "white"
@export var colour : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	goup()
	

func show_points(points, ColourMode):
	#get_node("Label").set_text = str(damge)
	set_colours(ColourMode)
	modulate = colour
	$Label.set_text(str(points))
	if visible == false:
		visible = true
	$AnimationPlayer.play("Showpoints")

func set_color(color):
	modulate = color

func set_colours(ColourMode):
	if ColourMode == "white":
		colour = Color(255,255,255)
	elif ColourMode == "red":
		colour = Color(255,0,0)
	elif ColourMode == "blue":
		colour = Color(0,0,255)
	elif ColourMode == "green":
		colour = Color(0,255,0)
	elif ColourMode == "yellow":
		colour = Color(255,255,0)
	elif ColourMode == "purple":
		colour = Color(255,0,255)
	elif ColourMode == "joke":
		colour = Color(150,75,0)
		
func goup():
	position.y -= 0.4
