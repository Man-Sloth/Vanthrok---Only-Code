extends Panel

@onready var vanthrok = $"../.."
@onready var backpack = $"."
@onready var exit_bag = $"Exit Bag"
@onready var title_plate = $"Title Plate"
#@onready var panel_container = $NinePatchRect2

@onready var player = $"../../Player"
@onready var scroll_container = $NinePatchRect2/ScrollContainer
@onready var nine_patch_rect_2 = $NinePatchRect2



var moving = false
var moving_start = Vector2(0,0)
var backpack_start = Vector2(0,0)
var hovering = false
var inventory_hover = false
const OBJECTSCENE = preload("res://Scenes/object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#bag_resize()
	bag_move()
	
func _input(event):
	if event.is_action_pressed("bag_toggle"):
		toggle_menu()
		
	if hovering && GameManager.get_held_object() != null: #Drop item back to previous slot
		if event.is_action_released("pickup"):
			var slot = GameManager.get_pulled_location()
			var char_slot = GameManager.get_pulled_char_location()
			if slot != null:
				var object = GameManager.get_held_object()
				slot.set_slot_object(OBJECTSCENE.instantiate())
				slot.get_slot_object().visible = false
				slot.get_slot_object().set_item_type(object.get_item_type())
				slot.add_child(slot.get_slot_object())
				slot.get_slot_object().get_node("AnimatedSprite2D").set_sprite_frames(object.get_node("AnimatedSprite2D").get_sprite_frames())
				object.delete()
				GameManager.set_texture(null)
				GameManager.set_held_object(null)
				GameManager.set_pulled_location(slot)
				GameManager.set_holding(false)
			if char_slot != null:
				var object = GameManager.get_held_object()
				char_slot.set_slot_object(OBJECTSCENE.instantiate())
				char_slot.get_slot_object().visible = false
				char_slot.get_slot_object().set_item_type(object.get_item_type())
				char_slot.add_child(char_slot.get_slot_object())
				char_slot.get_slot_object().get_node("AnimatedSprite2D").set_sprite_frames(object.get_node("AnimatedSprite2D").get_sprite_frames())
				object.delete()
				GameManager.set_texture(null)
				GameManager.set_held_object(null)
				GameManager.set_pulled_char_location(null)
				GameManager.set_holding(false)
	elif !hovering && !GameManager.get_hovering_slot(): #Drop item out of bag
		if event.is_action_released("pickup"):
			var slot = GameManager.get_pulled_location()
			if slot != null:
				if !GameManager.get_hovering_char_slot():
					if !GameManager.get_hovering_window():
						
						var object = GameManager.get_held_object()
						if object != null:
							var dropped_object = OBJECTSCENE.instantiate()
							dropped_object.set_item_type(object.get_item_type())
							vanthrok.add_child(dropped_object)
							dropped_object.get_node("AnimatedSprite2D").set_sprite_frames(object.get_node("AnimatedSprite2D").get_sprite_frames())
							dropped_object.position = player.position
							dropped_object.z_index = 1
							dropped_object.y_sort_enabled = true
							object.delete()
							GameManager.set_texture(null)
							GameManager.set_held_object(null)
							GameManager.set_pulled_location(null)
							GameManager.set_holding(false)
		
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
	
func _on_exit_bag_button_down():
	GameManager.set_button_pressed(true)

func _on_exit_bag_button_up():
	GameManager.set_button_pressed(false)

	
func _on_title_plate_button_down():
	moving = true
	moving_start = get_global_mouse_position()
	backpack_start = backpack.position
	GameManager.set_button_pressed(true)
	
func _on_title_plate_button_up():
	moving = false
	GameManager.set_button_pressed(false)

#func _on_panel_container_mouse_entered():
	#hovering = true
	#GameManager.set_hovering_window(true)
	
#func _on_panel_container_mouse_exited():
	#hovering = false
	#GameManager.set_hovering_window(false)

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

func _on_scroll_container_mouse_entered():
	inventory_hover = true


func _on_scroll_container_mouse_exited():
	inventory_hover = false


func _on_nine_patch_rect_2_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)

func _on_nine_patch_rect_2_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)




