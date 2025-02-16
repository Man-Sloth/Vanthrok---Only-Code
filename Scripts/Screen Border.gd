extends NinePatchRect
@onready var exit_button = $"Exit Button"
@onready var back_button = $"Back Button"

@export var multiplier = 1

var default_scale = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	get_viewport().connect("size_changed", _on_viewport_resize)

func _on_viewport_resize():
	size = get_viewport().size * multiplier
	
func _on_exit_button_pressed():
	get_tree().quit()
	
func _on_exit_button_mouse_entered():
	exit_button.scale.x = default_scale * 1.05
	exit_button.scale.y = default_scale * 1.05
	
func _on_exit_button_mouse_exited():
	exit_button.scale.x = default_scale
	exit_button.scale.y = default_scale

func _on_exit_button_button_down():
	exit_button.scale.x = default_scale * 0.95
	exit_button.scale.y = default_scale * 0.95

func _on_exit_button_button_up():
	exit_button.scale.x = default_scale * 1.05
	exit_button.scale.y = default_scale * 1.05


func _on_back_button_button_down():
	back_button.scale.x = default_scale * 0.95
	back_button.scale.y = default_scale * 0.95


func _on_back_button_button_up():
	back_button.scale.x = default_scale * 1.05
	back_button.scale.y = default_scale * 1.05


func _on_back_button_pressed():
	pass # Replace with function body.


func _on_back_button_mouse_entered():
	back_button.scale.x = default_scale * 1.05
	back_button.scale.y = default_scale * 1.05


func _on_back_button_mouse_exited():
	back_button.scale.x = default_scale
	back_button.scale.y = default_scale
