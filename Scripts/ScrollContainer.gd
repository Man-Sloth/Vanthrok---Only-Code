extends ScrollContainer
@onready var scroll_up = $"../../Scroll Up"
@onready var scroll_down = $"../../Scroll Down"
@onready var i_slots = $InventorySlots


var top_being_pushed = false
var bottom_being_pushed = false
var speed = 3500
var scale_shrink = 0.4
var scale_default = 0.5
const OBJECTSCENE = preload("res://Scenes/Objects/item.tscn")
var hovering = false
var max_scroll = 0

func _ready():
	max_scroll = i_slots.size.y - size.y
			
func _input(event):
	
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

	
func _process(delta):
	var scroll_amount = speed * delta
	if top_being_pushed:
		var current_scroll = self.get_v_scroll()
		#var scroll_amount = 250
		var new_scroll = current_scroll - scroll_amount
		self.set_v_scroll(new_scroll)
		top_being_pushed = true
	elif bottom_being_pushed:
		var current_scroll = self.get_v_scroll()
		#var scroll_amount =  250
		var new_scroll = current_scroll + scroll_amount
		self.set_v_scroll(new_scroll)
	if get_v_scroll() == 0:
		scroll_up.visible = false
	else:
		scroll_up.visible = true
	if get_v_scroll() >= max_scroll-1:
		scroll_down.visible = false
	else:
		scroll_down.visible = true
		
	if scroll_up.visible == false:
		top_being_pushed = false
		scroll_up.pivot_offset = Vector2(0, 0)
		scroll_up.scale = Vector2(scale_default, scale_default)
	if scroll_down.visible == false:
		bottom_being_pushed = false
		scroll_down.pivot_offset = Vector2(0, 0)
		scroll_down.scale = Vector2(scale_default, scale_default)

func _on_scroll_up_button_down():
	#var current_scroll = self.get_v_scroll()
	#var scroll_amount = 250
	#var new_scroll = current_scroll - scroll_amount
	#self.set_v_scroll(new_scroll)
	top_being_pushed = true
	scroll_up.scale = Vector2(scale_shrink, scale_shrink)
	scroll_up.pivot_offset = scroll_up.size / 10
	GameManager.set_button_pressed(true)
	
func _on_scroll_up_button_up():
	top_being_pushed = false
	scroll_up.scale = Vector2(scale_default, scale_default)
	scroll_up.pivot_offset = Vector2(0, 0)
	GameManager.set_button_pressed(false)
	
func _on_scroll_down_button_down():
	#var current_scroll = self.get_v_scroll()
	#var scroll_amount =  250
	#var new_scroll = current_scroll + scroll_amount
	#self.set_v_scroll(new_scroll)
	bottom_being_pushed = true
	scroll_down.scale = Vector2(scale_shrink, scale_shrink)
	scroll_down.pivot_offset = scroll_up.size / 10
	GameManager.set_button_pressed(true)
	
func _on_scroll_down_button_up():
	bottom_being_pushed = false
	scroll_down.scale = Vector2(scale_default, scale_default)
	scroll_down.pivot_offset = Vector2(0, 0)
	GameManager.set_button_pressed(false)

func _on_scroll_up_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)

func _on_scroll_up_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)

func _on_scroll_down_mouse_entered():
	hovering = true
	GameManager.set_hovering_window(true)

func _on_scroll_down_mouse_exited():
	hovering = false
	GameManager.set_hovering_window(false)

func _on_scroll_down_visibility_changed():
	if scroll_down != null:
		if scroll_down.visible == false:
			GameManager.set_button_pressed(false)

func _on_scroll_up_visibility_changed():
	if scroll_down != null:
		if scroll_up.visible == false:
			GameManager.set_button_pressed(false)


	
