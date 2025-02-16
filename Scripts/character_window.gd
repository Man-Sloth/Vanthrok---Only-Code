extends Panel

@onready var vanthrok = $"../.."
@onready var character_window = $"."
@onready var exit_window = $"Exit Window"
@onready var title_plate = $"Title Plate"
@onready var panel_container = $"PanelContainer"

@onready var player = $"../../Player"

@onready var chest = $Chest
@onready var chest_sprite = $"../../Player/Chest Sprite"
@onready var head = $Head
@onready var helmet_sprite = $"../../Player/Helm Sprite"
@onready var legs = $Legs
@onready var leggings_sprite = $"../../Player/Leggings Sprite"
@onready var arms = $Arms
@onready var gauntlet_sprite = $"../../Player/Gauntlet Sprite"
@onready var weapon = $Weapon
@onready var weapon_sprite = $"../../Player/Weapon Sprite"
@onready var shield = $Shield
@onready var shield_sprite = $"../../Player/Shield Sprite"


var moving = false
var moving_start = Vector2(0,0)
var character_window_start = Vector2(0,0)
var hovering = false
var inventory_hover = false

const OBJECTSCENE = preload("res://Scenes/object.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#window_resize()
	window_move()
	
func _input(event):
	if event.is_action_pressed("character_toggle"):
		toggle_menu()
		
	if hovering && GameManager.get_held_object() != null: #Drop item back to previous slot
		if event.is_action_released("pickup"):
			var slot = GameManager.get_pulled_char_location()
			var inv_slot = GameManager.get_pulled_location()
			if slot != null: 							# Dropping from another armor slot
				var object = GameManager.get_held_object()
				var item_type = object.get_item_type()
				var armor_type = object.get_armor_type()
				slot.set_slot_object(OBJECTSCENE.instantiate())
				slot.get_slot_object().visible = false
				slot.get_slot_object().set_item_type(object.get_item_type())
				slot.add_child(slot.get_slot_object())
				slot.get_slot_object().get_node("AnimatedSprite2D").set_sprite_frames(object.get_node("AnimatedSprite2D").get_sprite_frames())
				
				if armor_type == 0: #cloth
					if item_type == 1: #chest
					#chest.texture = DUMMY_CLOTH_SHIRT
						chest.visible = true
						chest_sprite.visible = true
					elif item_type == 0: #helmet
						#head.texture = DUMMY_CLOTH_HELMET
						head.visible = true
						helmet_sprite.visible = true
					elif item_type == 2: #leggings
						#legs.texture = DUMMY_CLOTH_LEGGINGS
						legs.visible = true
						leggings_sprite.visible = true
					elif item_type == 3: #Arms
						#arms.texture = DUMMY_CLOTH_ARMS
						arms.visible = true
						gauntlet_sprite.visible = true
					elif item_type == 4: #Weapon
						#weapon.texture = DUMMY_LEVEL1_SWORD
						weapon.visible = true
						weapon_sprite.visible = true	
					elif item_type == 5: #Shield
						#shield.texture = DUMMY_LEVEL1_SHIELD
						shield.visible = true
						shield_sprite.visible = true	
				object.delete()
				GameManager.set_texture(null)
				GameManager.set_held_object(null)
				GameManager.set_pulled_char_location(slot)
				GameManager.set_holding(false)
			elif inv_slot != null: 			#Dropping from an inventory slot
				var object = GameManager.get_held_object()
				inv_slot.set_slot_object(OBJECTSCENE.instantiate())
				inv_slot.get_slot_object().visible = false
				inv_slot.get_slot_object().set_item_type(object.get_item_type())
				inv_slot.add_child(inv_slot.get_slot_object())
				inv_slot.get_slot_object().get_node("AnimatedSprite2D").set_sprite_frames(object.get_node("AnimatedSprite2D").get_sprite_frames())
				
				# Release unwanted assets
				object.delete()
				GameManager.set_texture(null)
				GameManager.set_held_object(null)
				GameManager.set_pulled_location(null)
				GameManager.set_holding(false)
	elif !hovering && !GameManager.get_hovering_char_slot(): #Drop item out of window
		if event.is_action_released("pickup"):
			var slot = GameManager.get_pulled_char_location()
			if slot != null:
				if !GameManager.get_hovering_slot():
					if !GameManager.get_hovering_window():
						var object = GameManager.get_held_object()
						var dropped_object = OBJECTSCENE.instantiate()
						dropped_object.set_item_type(object.get_item_type())
						vanthrok.add_child(dropped_object)
						dropped_object.get_node("AnimatedSprite2D").set_sprite_frames(object.get_node("AnimatedSprite2D").get_sprite_frames())
						dropped_object.position = player.position
						dropped_object.z_index = 1
						dropped_object.y_sort_enabled = true
						dropped_object.set_item_type(slot.get_item_type())
						
						object.delete()
						GameManager.set_texture(null)
						GameManager.set_held_object(null)
						GameManager.set_pulled_location(null)
						GameManager.set_pulled_char_location(null)
						GameManager.set_holding(false)
		
func toggle_menu():
	if self.visible:
		self.visible = false
	else:
		self.visible = true

#func window_resize():
	#var speed = get_viewport_rect().size.x * 0.00001
	#var resizeDiff = abs(resize_window.position.x - get_local_mouse_position().x)
	#if resizing:
		#if resizeDiff > 20:
			#if resize_window.position.x + (resize_window.size.x/3) > (get_local_mouse_position().x + 0.1):
				#character_window.scale.x += (speed)
				#character_window.scale.y += (speed)
			#elif resize_window.position.x + (resize_window.size.x/3) < (get_local_mouse_position().x -0.1):
				#character_window.scale.x -= (speed)
				#character_window.scale.y -= (speed)
				#if character_window.scale.x < 0.5:
					#character_window.scale.x = 0.5
					#character_window.scale.y = 0.5

func window_move():
	if moving:
		character_window.position = character_window_start - (moving_start - get_global_mouse_position())

func is_hovering():
	return hovering

func _on_title_plate_button_down():
	moving = true
	moving_start = get_global_mouse_position()
	character_window_start = character_window.position
	GameManager.set_button_pressed(true)
	
func _on_title_plate_button_up():
	moving = false
	GameManager.set_button_pressed(false)

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

func _on_inventory_region_mouse_entered():
	inventory_hover = true
	
func _on_inventory_region_mouse_exited():
	inventory_hover = false

func _on_exit_window_pressed():
	toggle_menu()

func _on_exit_window_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)

func _on_exit_window_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)


func _on_exit_window_button_down():
	GameManager.set_button_pressed(true)

func _on_exit_window_button_up():
	GameManager.set_button_pressed(false)
