extends TextureRect


@onready var item_sprite = $item_sprite
@onready var player = $"../../../../../../Player"
@onready var map = $"../../../../../../../Map"


@export_group("Item Properties")
enum ITEM_TYPE {Helm, Chest, Legs, Arms, Weapon, Shield, Stackable, Non_Stackable, Empty = -1}
@export var Item_Type: ITEM_TYPE
const OBJECTSCENE = preload("res://Scenes/object.tscn")
var holdOffset = Vector2(115,170)
enum armor_mat {CLOTH} 
var hovering = false
var object = null
var slot_object = null
var loaded_animation = AnimatedSprite2D.new()
var dummy_image = Sprite2D.new()
var load_thread = Thread.new()
#var new_animation = load("res://Assets/sprites/SpriteFrames/Human_BLANK.tres")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	animate()
	
func _input(event):
	if hovering && GameManager.get_held_object() != null: #drop item into slot
		if event.is_action_released("pickup"):
			object = GameManager.get_held_object()
			if slot_object == null: # Drop into empty slot
				slot_object = OBJECTSCENE.instantiate()
				slot_object.visible = false
				slot_object.set_item_type(object.get_item_type())
				slot_object.set_armor_type(object.get_armor_type())
				Item_Type = slot_object.get_item_type()
				slot_object.set_resource_path(object.get_resource_path())
				add_child(slot_object)
				
				add_animation(slot_object)
				
				object.delete()
				GameManager.set_texture(null)
				GameManager.set_held_object(null)
				GameManager.set_pulled_location(null)
				GameManager.set_pulled_char_location(null)
				
			else: # Drop into a slot from the ground to a filled slot (Swap)
				if GameManager.get_pulled_location() == null:
					var ground_object = OBJECTSCENE.instantiate()
					ground_object.visible = false
					ground_object.set_item_type(slot_object.get_item_type())
					ground_object.set_armor_type(slot_object.get_armor_type())
					ground_object.set_resource_path(slot_object.get_resource_path())
					map.add_child(ground_object)
					add_animation(ground_object)
					ground_object.position = player.position
					ground_object.visible = true
					
					slot_object = OBJECTSCENE.instantiate()
					slot_object.visible = false
					slot_object.animated_sprite_2d = object.animated_sprite_2d
					slot_object.set_item_type(object.get_item_type())
					slot_object.set_armor_type(object.get_armor_type())
					slot_object.set_resource_path(object.get_resource_path())
					get_child(1).delete()
					
					slot_object.update_stats()
					add_child(slot_object)
					add_animation(slot_object)
					
					object.delete()
					GameManager.set_texture(null)
					GameManager.set_held_object(null)
					GameManager.set_pulled_location(null)
					GameManager.set_pulled_char_location(null)
				
				else: # move from 1 filled slot to another filled slot (swap)			
					var new_slot_object = OBJECTSCENE.instantiate()
					new_slot_object.set_item_type(GameManager.get_held_object().get_item_type())
					new_slot_object.set_armor_type(GameManager.get_held_object().get_armor_type())
					
					GameManager.get_held_object().set_item_type(self.get_child(1).get_item_type())
					GameManager.get_held_object().set_armor_type(self.get_child(1).get_armor_type())
					
					self.get_child(1).set_item_type(new_slot_object.get_item_type())
					self.get_child(1).set_armor_type(new_slot_object.get_armor_type())
					
					GameManager.get_held_object().get_parent().slot_object = GameManager.get_held_object()
					var as2d = self.get_child(1).animated_sprite_2d
					GameManager.get_held_object().get_parent().get_child(0).texture = as2d.sprite_frames.get_frame_texture(as2d.animation, 0)
					
					var tmp_image = GameManager.get_held_object().dummy_image
					GameManager.get_held_object().dummy_image = self.get_child(1).dummy_image
					self.get_child(1).dummy_image = tmp_image
					
					var tmp_frames = GameManager.get_held_object().get_frames()
					GameManager.get_held_object().set_frames(self.get_child(1).get_frames())
					self.get_child(1).set_frames(tmp_frames)
					
					GameManager.get_held_object().update_stats()
					self.get_child(1).update_stats()
					
					GameManager.set_texture(null)
					GameManager.set_held_object(null)
					GameManager.set_pulled_location(null)
					GameManager.set_pulled_char_location(null)

	elif hovering && GameManager.get_held_object() == null: #pick up item from slot
		if event.is_action_pressed("pickup"):
			if slot_object != null:
				GameManager.set_held_object(slot_object)
				GameManager.set_holding(true)
				GameManager.set_held_position(event.position - holdOffset)
				slot_object = null
				item_sprite.texture = null
				GameManager.set_pulled_location(self)
			
func animate():
	if slot_object != null:
		var animatedSprite2D = slot_object.get_node("AnimatedSprite2D")
		var frameIndex: int = animatedSprite2D.get_frame()
		var animationName: String = animatedSprite2D.animation
		var spriteFrames: SpriteFrames = animatedSprite2D.get_sprite_frames()
		item_sprite.texture = spriteFrames.get_frame_texture(animationName, frameIndex)

func add_animation(object):
	var path = object.get_resource_path()
	var dummy_path = object.get_dummy_path()
	var armor_type = object.get_armor_type()
	start_load_thread(path, dummy_path)

func start_load_thread(path, dummy_path):
	load_thread = Thread.new()
	load_thread.start(load_resource.bind(path, dummy_path))
		
func load_resource(path, dummy_path):
	var new_animation = AnimatedSprite2D.new()
	var new_dummy_image = Sprite2D.new()
	new_animation.sprite_frames = load(path)
	new_dummy_image.texture = load(dummy_path)
	call_deferred("set_animation_frames", new_animation, new_dummy_image)
	
func set_animation_frames(new_animation, new_dummy_image):
	load_thread.wait_to_finish()
	loaded_animation.sprite_frames = new_animation.sprite_frames
	dummy_image.texture = new_dummy_image.texture
	slot_object.set_frames(loaded_animation)
	slot_object.set_dummy(dummy_image)

func _on_mouse_entered():
	GameManager.set_hovering_slot(true)
	hovering = true

func _on_mouse_exited():
	GameManager.set_hovering_slot(false)
	hovering = false
	
func set_slot_object(new_object):
	slot_object = new_object
	
func get_slot_object():
	return slot_object
	
func get_item_type():
	return Item_Type
	
func set_item_type(type):
	Item_Type = type
