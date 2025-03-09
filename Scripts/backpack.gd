extends Panel

@onready var vanthrok = $"../.."
@onready var backpack = $"."
@onready var exit_bag = $"Exit Bag"
@onready var title_plate = $"Title Plate"
#@onready var panel_container = $NinePatchRect2
@onready var dummy_legs = $"/root/OmegaScene/Map/CanvasLayer/CharacterWindow/Legs"
@onready var dummy_chest = $"/root/OmegaScene/Map/CanvasLayer/CharacterWindow/Chest"
@onready var dummy_head = $"/root/OmegaScene/Map/CanvasLayer/CharacterWindow/Head"
@onready var dummy_arms = $"/root/OmegaScene/Map/CanvasLayer/CharacterWindow/Arms"
@onready var dummy_weapon = $"/root/OmegaScene/Map/CanvasLayer/CharacterWindow/Weapon"
@onready var dummy_shield = $"/root/OmegaScene/Map/CanvasLayer/CharacterWindow/Shield"

@onready var player = $"../../Player"
@onready var scroll_container = $NinePatchRect2/ScrollContainer
@onready var nine_patch_rect_2 = $NinePatchRect2
@onready var equip = $"../CharacterWindow/Equip"
@onready var item_tooltip




var moving = false
var moving_start = Vector2(0,0)
var backpack_start = Vector2(0,0)
var hovering = false
var inventory_hover = false
const OBJECTSCENE = preload("res://Scenes/Objects/item.tscn")
var ground_object = OBJECTSCENE.instantiate()

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
			if hovering:
				var slot = GameManager.get_pulled_location()
				var char_slot = GameManager.get_pulled_char_location()
				if slot != null:
					var object = GameManager.get_held_object()
					var object_dict = object.load_clone()
					add_animations(object_dict, slot)
					if object_dict["item_type"] == 6: 
						slot.get_node("item_sprite/Label").text = str(object_dict["stack_size"])
						slot.get_node("item_sprite/Label").visible = true
					object.delete()
					GameManager.clear()
				if char_slot != null:
					equip.play()
					var object = GameManager.get_held_object()
					var object_dict = object.load_clone()
					add_animations(object_dict, char_slot)
					
					if object_dict["armor_type"] == 0: #cloth
						if object_dict["item_type"] == 1: #chest
							dummy_chest.texture = char_slot.get_slot_object().get_dummy().texture
							dummy_chest.visible = true
							dummy_chest.visible = true
						elif object_dict["item_type"] == 0: #helmet
							dummy_head.texture = char_slot.get_slot_object().get_dummy().texture
							dummy_head.visible = true
							dummy_head.visible = true
						elif object_dict["item_type"] == 2: #leggings
							dummy_legs.texture = char_slot.get_slot_object().get_dummy().texture
							dummy_legs.visible = true
							dummy_legs.visible = true
						elif object_dict["item_type"] == 3: #Arms
							dummy_arms.texture = char_slot.get_slot_object().get_dummy().texture
							dummy_arms.visible = true
							dummy_arms.visible = true
						elif object_dict["item_type"] == 4: #Weapon
							dummy_weapon.texture = char_slot.get_slot_object().get_dummy().texture
							dummy_weapon.visible = true
							dummy_weapon.visible = true	
						elif object_dict["item_type"] == 5: #Shield
							dummy_shield.texture = char_slot.get_slot_object().get_dummy().texture
							dummy_shield.visible = true
							dummy_shield.visible = true
						
							
						player.set_frames(char_slot.get_slot_object())
					
					
					object.delete()
					GameManager.clear()
	elif !hovering && GameManager.get_held_object() != null && GameManager.last_container == "Backpack": #Drop item out of window
		if event.is_action_released("pickup"):
			if !GameManager.get_hovering_char_slot():
				if !GameManager.get_hovering_window():
					
					var object = GameManager.get_held_object()
					if object != null:
						transfer_to_ground(object.load_clone())
						var mouse_pos = player.get_local_mouse_position()
						var dir = (mouse_pos - player.position).normalized()
						ground_object.position = player.position + (dir*20)
						
						ground_object.z_index = 1
						ground_object.y_sort_enabled = true
						ground_object.item = GameManager.get_held_object().item
						if ground_object.item["tag"] == "potion":
							ground_object.get_node("shadow").offset.x = -5
							ground_object.get_node("shadow").offset.y -= 25
							ground_object.get_node("shadow").skew = -20
							ground_object.get_node("shadow").rotation = 0
							ground_object.get_node("shadow").scale = Vector2(1, .75)
						else:
							ground_object.get_node("shadow").offset.x = -10
							ground_object.get_node("shadow").offset.y = -25
							ground_object.get_node("shadow").scale = Vector2(.50, .50)
						
						vanthrok.add_child(ground_object)
						object.delete()
						GameManager.clear()
			
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

func add_animations(obj_dict, slot):
	slot.set_slot_object(OBJECTSCENE.instantiate())
	slot.get_slot_object().visible = obj_dict["visible"]
	slot.get_slot_object().set_item_type(obj_dict["item_type"])
	slot.get_slot_object().set_armor_type(obj_dict["armor_type"])
	slot.get_slot_object().set_resource_path(obj_dict["path"])
	slot.get_slot_object().set_attack_path(obj_dict["attack_path"])
	slot.get_slot_object().set_dummy_path(obj_dict["dummy_path"]) 
	slot.get_slot_object().dummy_image = obj_dict["dummy_sprite"]
	slot.get_slot_object().object_animations = obj_dict["frames"]	
	slot.get_slot_object().attack_animations = obj_dict["attack_frames"]
	slot.get_slot_object().stack_size = obj_dict["stack_size"]
	slot.get_slot_object().tag= obj_dict["tag"]
	slot.add_child(slot.get_slot_object())
	
func transfer_to_ground(obj_dict):
	ground_object = OBJECTSCENE.instantiate()
	ground_object.visible = true
	ground_object.set_item_type(obj_dict["item_type"])
	ground_object.set_armor_type(obj_dict["armor_type"])
	ground_object.set_resource_path(obj_dict["path"])
	ground_object.set_attack_path(obj_dict["attack_path"])
	ground_object.set_dummy_path(obj_dict["dummy_path"]) 
	ground_object.dummy_image = obj_dict["dummy_sprite"]
	ground_object.object_animations = obj_dict["frames"]	
	ground_object.attack_animations = obj_dict["attack_frames"]
	ground_object.stack_size = obj_dict["stack_size"]
	ground_object.tag = obj_dict["tag"]

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
		
func _on_name_ready():
	item_tooltip = $ItemTooltip
	GameManager.set_bag_tooltip(item_tooltip)
