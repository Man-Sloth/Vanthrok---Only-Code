extends TextureRect

@export var day_night: Node2D
var day_night_anim

# Called when the node enters the scene tree for the first time.
func _ready():
	day_night_anim = day_night.get_node("AnimatedSprite2D")
	#day_night_anim.play("default")
	day_night_anim.frame = GameManager.tod
	texture = day_night_anim.sprite_frames.get_frame_texture("default", day_night_anim.frame)

func _process(_delta):
	texture = day_night_anim.sprite_frames.get_frame_texture("default", day_night_anim.frame)
