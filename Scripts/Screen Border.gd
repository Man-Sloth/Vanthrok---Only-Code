extends NinePatchRect

var exit_button
var back_button

var multiplier = 1
var character_selection
var login_window
var character_creation


var default_scale = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	if(name == "Background"):
		exit_button = $"Exit Button"
		back_button = $"Back Login"
		character_selection = $"/root/OmegaScene/CanvasLayer/Control/Character Selection"
		character_creation = $"/root/OmegaScene/CanvasLayer/Control/Character Creation"
		login_window = $"/root/OmegaScene/CanvasLayer/Control/LoginWindow"
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

func _on_back_login_pressed():
	if character_selection.visible:
		GameManager.logged_in = false
		character_selection.visible = false
		login_window.visible = true
		back_button.visible = false
		login_window.get_node("LoginScreen/Login Button").disabled = false
		login_window.get_node("LoginScreen/Create Account").disabled = false
		GameServer.disconnect_from_server()
	else:
		character_selection.visible = true
		character_creation.visible = false

func _on_back_login_button_down():
	back_button.scale.x = default_scale * 0.95
	back_button.scale.y = default_scale * 0.95

func _on_back_login_button_up():
	back_button.scale.x = default_scale * 1.05
	back_button.scale.y = default_scale * 1.05

func _on_back_login_mouse_entered():
	back_button.scale.x = default_scale * 1.05
	back_button.scale.y = default_scale * 1.05

func _on_back_login_mouse_exited():
	back_button.scale.x = default_scale
	back_button.scale.y = default_scale
