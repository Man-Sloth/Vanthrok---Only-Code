extends ScrollContainer

const OBJECTSCENE = preload("res://Scenes/object.tscn")
var hovering = false


			
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
