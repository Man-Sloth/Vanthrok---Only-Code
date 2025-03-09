extends Area2D

@onready var sprite_2d = $Sprite2D
@onready var door_sound = $DoorSound
@onready var door_sound_2 = $DoorSound2
@onready var timer = $Timer
@onready var player = $"../../../Player"
var door_open = false

func _ready():
	timer = $Timer
	if timer == null:
		push_error("Timer node not found! Add a Timer as a child of this Area2D.")
		return

	timer.connect("timeout", _on_timer_timeout)
	sprite_2d.visible = true
func _on_body_entered(body):
	if body == player:
		if !door_open:
			door_open = true
			sprite_2d.visible = false
			door_sound.play()

func _on_body_exited(_body):
	timer.start(2.0)  # Start the timer when the body EXITS

func _on_timer_timeout():
	door_open = false
	door_sound_2.play()
	sprite_2d.visible = true  # Close the door
	timer.stop() # Stop the timer to prevent it from triggering again
