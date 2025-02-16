extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var door_sound = $DoorSound
@onready var door_sound_2 = $DoorSound2
@onready var timer = $Timer

var door_open = true

func _ready():
	timer = $Timer
	if timer == null:
		push_error("Timer node not found! Add a Timer as a child of this Area2D.")
		return

	timer.connect("timeout", _on_timer_timeout)

	door_open = animated_sprite_2d.visible
	if not door_open:
		timer.start(2.0)

func _on_body_entered(_body):
	if door_open:
		door_open = false
		animated_sprite_2d.visible = false
		door_sound.play()

func _on_body_exited(_body):
	timer.start(2.0)  # Start the timer when the body EXITS

func _on_timer_timeout():
	door_open = true
	door_sound_2.play()
	animated_sprite_2d.visible = true  # Close the door
	timer.stop() # Stop the timer to prevent it from triggering again
