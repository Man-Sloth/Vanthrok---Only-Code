extends Panel

@onready var vanthrok = $"../.."
@onready var backpack = $"."
@onready var exit_bag = $"Exit Bag"
@onready var title_plate = $"Title Plate"
@onready var panel_container = $"PanelContainer"


var resizing = false
var moving = false
var moving_start = Vector2(0,0)
var backpack_start = Vector2(0,0)
var hovering = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#bag_resize()
	bag_move()
	
func _input(event):
	if event.is_action_pressed("Controls"):
		toggle_menu()
		
func toggle_menu():
	if self.visible:
		self.visible = false
	else:
		self.visible = true
		
#func bag_resize():
	#var speed = get_viewport_rect().size.x * 0.00001
	#var resizeDiff = abs(resize_bag.position.x - get_local_mouse_position().x)
	#if resizing:
		#if resizeDiff > 20:
			#if resize_bag.position.x + (resize_bag.size.x/3) > (get_local_mouse_position().x + 0.1):
				#backpack.scale.x += (speed)
				#backpack.scale.y += (speed)
			#elif resize_bag.position.x + (resize_bag.size.x/3) < (get_local_mouse_position().x -0.1):
				#backpack.scale.x -= (speed)
				#backpack.scale.y -= (speed)
				#if backpack.scale.x < 0.5:
					#backpack.scale.x = 0.5
					#backpack.scale.y = 0.5
func bag_move():
	if moving:
		backpack.position = backpack_start - (moving_start - get_global_mouse_position())

func is_hovering():
	return hovering

func _on_exit_bag_pressed():
	toggle_menu()

func _on_resize_bag_button_down():
	resizing = true

func _on_resize_bag_button_up():
	resizing = false

func _on_title_plate_button_down():
	moving = true
	moving_start = get_global_mouse_position()
	backpack_start = backpack.position
	
func _on_title_plate_button_up():
	moving = false

func _on_panel_container_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)
	
func _on_panel_container_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)

func _on_title_plate_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)

func _on_title_plate_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)

func _on_exit_bag_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)

func _on_exit_bag_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)

func _on_resize_bag_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)
	
func _on_resize_bag_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)
