extends Node


@onready var texture_rect = $"../OmegaScene/Map/CanvasLayer/Mouse_Held_Item/TextureRect"


const MAP = preload("res://Scenes/Map.tscn")

var score = 0
var holding = false
var holding_last_frame = false
var last_texture = null
var held_object = null
var ground_object = null
var last_pulled_from = null #bag slot
var last_pulled_from_char = null #character window slot
var hovering_slot = false
var hovering_char_slot = false
var hovering_window = false
var button_pressed = false
var item_hovered = false
var swapped = null
var mouse_regular = preload("res://Assets/sprites/UI/Mouse Cursor/MouseCursor.png")
var mouse_clicked = preload("res://Assets/sprites/UI/Mouse Cursor/MouseCursor2.png")
const ATTACK_CURSOR = preload("res://Assets/sprites/UI/Mouse Cursor/AttackCursor.png")


#@onready var score_label = %ScoreLabel

func _process(_delta):
	if holding_last_frame:
		if !holding:
			set_button_pressed(false)
	if holding:
		var animatedSprite2D = held_object.get_node("AnimatedSprite2D")
		var frameIndex: int = animatedSprite2D.get_frame()
		var animationName: String = animatedSprite2D.animation
		var spriteFrames: SpriteFrames = animatedSprite2D.get_sprite_frames()
		var currentTexture: Texture2D = spriteFrames.get_frame_texture(animationName, frameIndex)
		set_texture(currentTexture)
		holding_last_frame = true
		set_button_pressed(true)
	else:
		holding_last_frame = false
		

func _input(event):
		
		
	var holdOffset = Vector2(110,165)
	
	if event.is_action_pressed("pickup") && holding:
		set_held_position(event.position - holdOffset)
	
	if event.is_action_released("pickup") && holding:
		holding = false
		held_object = null
		set_held_position(Vector2(-10000, -10000))
	if event is InputEventMouseMotion:
		if(holding):
			set_held_position(event.position - holdOffset)
			
func get_texture():
	return texture_rect.texture

func set_texture(new_texture):
	texture_rect.texture = new_texture
	if new_texture != null:
		last_texture = new_texture
	
func get_last_texture():
	return last_texture

func get_held_position():
	return texture_rect.position

func set_held_position(position):
	texture_rect.position = position

func set_held_object(object):
	held_object = object

func get_held_object():
	return held_object
	
func update_held_item():
	held_object.update_stats()
	
func set_ground_item(object):
	ground_object = object

func update_ground_item(new_object):
	ground_object.set_item_type(new_object.get_item_type())
	ground_object.set_armor_type(new_object.get_armor_type())
	ground_object.update_stats()
	
func set_holding(isHolding):
	holding = isHolding

func is_holding():
	return holding
	
func set_pulled_location(location):
	last_pulled_from = location

func get_pulled_location():
	return last_pulled_from
	
func set_pulled_char_location(location):
	if location == null:
		pass
	last_pulled_from_char = location
	
func get_pulled_char_location():
	return last_pulled_from_char
	
func set_hovering_slot(hovering):
	hovering_slot = hovering

func get_hovering_slot():
	return hovering_slot
	
func set_hovering_char_slot(hovering):
	hovering_char_slot = hovering
	
func get_hovering_char_slot():
	return hovering_char_slot
	
func set_hovering_window(hovering):
	hovering_window = hovering
	
func get_hovering_window():
	return hovering_window
	
func set_item_hovered(hovered):
	item_hovered = hovered
	
func set_button_pressed(is_pressed):
	button_pressed = is_pressed
	if button_pressed:
			Input.set_custom_mouse_cursor(mouse_clicked)
	elif !button_pressed:
		Input.set_custom_mouse_cursor(mouse_regular)
	
func set_attack_cursor(is_set):
	if !holding && !hovering_window && !hovering_char_slot && !hovering_slot && !item_hovered:
		if is_set:
			Input.set_custom_mouse_cursor(ATTACK_CURSOR)
		else:
			if !button_pressed:
				Input.set_custom_mouse_cursor(mouse_regular)
	
	if hovering_window or hovering_char_slot or hovering_slot or item_hovered:
		if !holding && !button_pressed:
			Input.set_custom_mouse_cursor(mouse_regular)
			
func save_swap(swap):
	swapped = swap

func place_swapped():
	var swap = swapped
	swapped = null
	return swap
