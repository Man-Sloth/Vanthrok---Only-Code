extends Control

@onready var login_screen = $"LoginScreen"
@onready var username_input = $"LoginScreen/Username Input"
@onready var password_input = $"LoginScreen/Password Input"

@onready var login_button = $"LoginScreen/Login Button"
@onready var create_account_button = $"LoginScreen/Create Account"

@onready var create_account_screen = $"CreateAccountScreen"
@onready var create_username = $"CreateAccountScreen/Username Input"
@onready var create_password = $"CreateAccountScreen/Password Input"
@onready var confirm_password = $"CreateAccountScreen/Password Input2"

@onready var confirm_button = $"CreateAccountScreen/ConfirmButton"
@onready var back_button = $"CreateAccountScreen/BackButton"

var default_scale = 0.5

func _on_login_button_pressed():
	
	if username_input.text == "" or password_input.text == "":
		#make pop up later?
		print("Please provide valid userID and password")
	else:
		login_button.disabled = true
		create_account_button.disabled = true
		var username = username_input.get_text()
		var password = password_input.get_text()
		print("Attempting to login")
		Gateway.ConnectToServer(username, password)

func _on_create_account_pressed():
	login_screen.hide()
	create_account_screen.show()
	
func _on_back_button_pressed():
	create_account_screen.hide()
	login_screen.show()

func _on_confirm_button_pressed():
	if create_username.get_text() == "":
		print("Please provide a valid username")
	elif create_password.get_text() == "":
		print("Please provide a valid password")
	elif confirm_password.get_text() == "":
		print("Please re-type your password")
	elif create_password.get_text() != confirm_password.get_text():
		print("Passwords don't match! Type them the same way!")
	elif create_password.get_text().length() <= 6:
		print("Password must contain at least 7 characters")
	else:
		confirm_button.disabled = true
		back_button.disabled = true
		var username = create_username.get_text()
		var password = create_password.get_text()
		Gateway.ConnectToServer(username, password, true)

func _on_login_button_mouse_entered():
	login_button.scale.x = default_scale * 1.05
	login_button.scale.y = default_scale * 1.05
	
func _on_login_button_mouse_exited():
	login_button.scale.x = default_scale
	login_button.scale.y = default_scale

func _on_login_button_button_down():
	GameManager.set_button_pressed(true)
	login_button.scale.x = default_scale * 0.95
	login_button.scale.y = default_scale * 0.95
	
func _on_create_account_mouse_entered():
	create_account_button.scale.x = default_scale * 1.05
	create_account_button.scale.y = default_scale * 1.05

func _on_create_account_mouse_exited():
	create_account_button.scale.x = default_scale
	create_account_button.scale.y = default_scale

func _on_create_account_button_down():
	GameManager.set_button_pressed(true)
	create_account_button.scale.x = default_scale * 0.95
	create_account_button.scale.y = default_scale * 0.95

func _on_confirm_button_mouse_entered():
	confirm_button.scale.x = default_scale * 1.05
	confirm_button.scale.y = default_scale * 1.05

func _on_confirm_button_mouse_exited():
	confirm_button.scale.x = default_scale
	confirm_button.scale.y = default_scale

func _on_confirm_button_button_down():
	GameManager.set_button_pressed(true)
	confirm_button.scale.x = default_scale * 0.95
	confirm_button.scale.y = default_scale * 0.95

func _on_back_button_mouse_entered():
	back_button.scale.x = default_scale * 1.05
	back_button.scale.y = default_scale * 1.05

func _on_back_button_mouse_exited():
	back_button.scale.x = default_scale
	back_button.scale.y = default_scale

func _on_back_button_button_down():
	GameManager.set_button_pressed(true)
	back_button.scale.x = default_scale * 0.95
	back_button.scale.y = default_scale * 0.95

func _on_confirm_button_button_up():
	GameManager.set_button_pressed(false)
	confirm_button.scale.x = default_scale * 1.05
	confirm_button.scale.y = default_scale * 1.05

func _on_login_button_button_up():
	GameManager.set_button_pressed(false)
	login_button.scale.x = default_scale * 1.05
	login_button.scale.y = default_scale * 1.05

func _on_create_account_button_up():
	GameManager.set_button_pressed(false)

func _on_back_button_button_up():
	GameManager.set_button_pressed(false)
