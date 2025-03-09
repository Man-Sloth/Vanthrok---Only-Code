extends TextureRect


@onready var item_sprite = $item_sprite
@onready var player = $"../../../../Player"
@onready var chest_sprite = $"../../../../Player/Chest Sprite"
@onready var helmet_sprite = $"../../../../Player/Helm Sprite"
@onready var leggings_sprite = $"../../../../Player/Leggings Sprite"
@onready var gauntlets_sprite = $"../../../../Player/Gauntlet Sprite"
@onready var weapon_sprite = $"../../../../Player/Weapon Sprite"
@onready var shield_sprite = $"../../../../Player/Shield Sprite"
@onready var equip = $"../../Equip"
@onready var cutout = $"item_sprite/Cutout"


@onready var chest = $"../../Chest"
@onready var head = $"../../Head"
@onready var legs = $"../../Legs"
@onready var arms = $"../../Arms"
@onready var weapon = $"../../Weapon"
@onready var shield = $"../../Shield"


@export_group("Item Properties")
enum ITEM_TYPE {Helm, Chest, Legs, Arms, Weapon, Shield, Stackable, Non_Stackable = -1}
@export var Item_Type: ITEM_TYPE
var armor_type_last_frame = -1

const OBJECTSCENE = preload("res://Scenes/Objects/item.tscn")
var loaded_animations = {"normal_frames": SpriteFrames.new(), "attack_frames": SpriteFrames.new(), "dummy_sprite": AtlasTexture.new()}

var holdOffset = Vector2(115,170)

var hovering = false
var object = null
var slot_object = null
var clone = {}
var cloned_item = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	animate()
	
func _input(event):
	if hovering && GameManager.get_held_object() != null : # mouse is holding an item
		if !GameManager.get_pulled_location() == null or !GameManager.get_pulled_char_location() == null:
			if GameManager.get_held_object().get_item_type() == Item_Type: # item can be dropped in this location
				if event.is_action_released("pickup"):
					GameManager.save_clone(GameManager.get_held_object().load_clone())
					var object_dict = GameManager.get_clone()
					add_animations(object_dict)
					cutout.visible = false
					modulate = Color(1,1,1,1)
					if clone["armor_type"] != armor_type_last_frame: # new armor type was placed in location. Need to load new asset
						if clone["armor_type"] == 0: #cloth
							if clone["item_type"] == 1: #chest
								chest.visible = true
								chest_sprite.visible = true
								player.shirt_on = true
							elif clone["item_type"] == 0: #Helm
								head.visible = true
								helmet_sprite.visible = true
								player.hat_on = true
							elif clone["item_type"] == 2: #Leggings
								legs.visible = true
								leggings_sprite.visible = true
								player.pants_on = true
							elif clone["item_type"] == 3: #Gauntlets
								arms.visible = true
								gauntlets_sprite.visible = true
								player.gloves_on = true
							elif clone["item_type"] == 4: #Weapon
								weapon.visible = true
								weapon_sprite.visible = true
								player.weapon_on = true
							elif clone["item_type"] == 5: #Shield
								shield.visible = true
								shield_sprite.visible = true
								player.shield_on = true
						armor_type_last_frame = clone["armor_type"]
						
						player.set_frames(cloned_item)
					
						# New way of loading dummy
						if clone["item_type"] == 1: #chest
							chest.texture = cloned_item.get_dummy().texture
							chest.visible = true
							equip.play()
						elif clone["item_type"] == 0: #Helm
							head.texture = cloned_item.get_dummy().texture
							head.visible = true
							equip.play()
						elif clone["item_type"] == 2: #Leggings
							legs.texture = cloned_item.get_dummy().texture
							legs.visible = true
							equip.play()
						elif clone["item_type"] == 3: #Gauntlets
							arms.texture = cloned_item.get_dummy().texture
							arms.visible = true
							equip.play()
						elif clone["item_type"] == 4: #Weapon
							weapon.texture = cloned_item.get_dummy().texture
							weapon.visible = true
							equip.play()
						elif clone["item_type"] == 5: #Shield
							shield.texture = cloned_item.get_dummy().texture
							shield.visible = true
							equip.play()
						var inv_slot = GameManager.get_pulled_location()
						if inv_slot != null: 
							inv_slot.cloned_item = null
						#object.delete()
						GameManager.clear()
					
			else: # item CANNOT be dropped at this location
				var slot = GameManager.get_pulled_char_location()
				var inv_slot = GameManager.get_pulled_location()
				if slot != null: #Pulled from another armor slot
					if event.is_action_released("pickup"):
						equip.play()
						var h_object = GameManager.get_held_object()
						var object_dict = h_object.load_clone()
						return_to_slot(object_dict, slot)
						
						if object_dict["armor_type"] == 0: #cloth
							if object_dict["item_type"] == 1: #chest
								chest.texture = slot.get_slot_object().get_dummy().texture
								chest.visible = true
								chest_sprite.visible = true
							elif object_dict["item_type"] == 0: #Helm
								head.texture = slot.get_slot_object().get_dummy().texture
								head.visible = true
								helmet_sprite.visible = true
							elif object_dict["item_type"] == 2: #leggings
								legs.texture = slot.get_slot_object().get_dummy().texture
								legs.visible = true
								leggings_sprite.visible = true	
							elif object_dict["item_type"] == 3: #gloves
								arms.texture = slot.get_slot_object().get_dummy().texture
								arms.visible = true
								gauntlets_sprite.visible = true	
							elif object_dict["item_type"] == 4: #weapon
								weapon.texture = slot.get_slot_object().get_dummy().texture
								weapon.visible = true
								weapon_sprite.visible = true		
							elif object_dict["item_type"] == 5: #Shield
								shield.texture = slot.get_slot_object().get_dummy().texture
								shield.visible = true
								shield_sprite.visible = true	
									
						h_object.delete()
						GameManager.clear()
				elif inv_slot != null: # pulled from a bag slot
					if event.is_action_released("pickup"):
						var h_object = GameManager.get_held_object()
						var object_dict = h_object.load_clone()
						return_to_slot(object_dict, inv_slot)
						
						h_object.delete()
						GameManager.clear()
						
	elif hovering && GameManager.get_held_object() == null: # Mouse is NOT holding an item
		if event.is_action_pressed("pickup"): # pick up an item from this armor slot
			if cloned_item != null:
				cutout.visible = true
				modulate = Color(.41,.41,.41,1)
				var item_type = cloned_item.get_item_type()
				GameManager.set_held_object(cloned_item)
				GameManager.set_holding(true)
				GameManager.set_held_position(event.position - holdOffset)
				GameManager.set_pulled_char_location(self)

				remove_child(get_child(1))
				item_sprite.texture = null
				cloned_item = null
				
				#if armor_type == 0: #cloth
				if item_type == 1: #chest
					chest.texture =null
					chest.visible = false
					chest_sprite.visible = false
					player.shirt_on = false
				elif item_type == 0: #head
					head.texture = null
					head.visible = false
					helmet_sprite.visible = false
					player.hat_on = false
				elif item_type == 2: #leggings
					legs.texture = null
					legs.visible = false
					leggings_sprite.visible = false
					player.pants_on = false
				elif item_type == 3: #gloves
					arms.texture = null
					arms.visible = false
					gauntlets_sprite.visible = false
					player.gloves_on = false
				elif item_type == 4: #weapon
					weapon.texture = null
					weapon.visible = false
					weapon_sprite.visible = false
					player.weapon_on = false
				elif item_type == 5: #Shield
					shield.texture = null
					shield.visible = false
					shield_sprite.visible = false
					player.shield_on = false
				armor_type_last_frame = -1
	
func animate():
	if cloned_item != null:
		var animatedSprite2D = cloned_item.get_node("AnimatedSprite2D")
		var frameIndex: int = animatedSprite2D.get_frame()
		var animationName: String = animatedSprite2D.animation
		var spriteFrames: SpriteFrames = animatedSprite2D.get_sprite_frames()
		item_sprite.texture = spriteFrames.get_frame_texture(animationName, frameIndex)

func add_animations(object_dict):
	
	cloned_item = OBJECTSCENE.instantiate()
	clone = object_dict
	cloned_item.save_clone(clone)
	
	cloned_item.set_frames(load(clone["path"]))
	cloned_item.set_attack_frames(load(clone["attack_path"]))
	cloned_item.set_dummy(clone["dummy_sprite"])
	
	add_child(cloned_item)
		
func return_to_slot(obj_dict, slot):
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
	slot.get_slot_object().tag = obj_dict["tag"]
	slot.add_child(slot.get_slot_object())

func _on_mouse_entered():
	GameManager.set_hovering_char_slot(true)
	hovering = true

func _on_mouse_exited():
	GameManager.set_hovering_char_slot(false)
	hovering = false
	
func set_slot_object(new_object):
	slot_object = new_object
	cloned_item = slot_object
	
func get_slot_object():
	return slot_object
	
func get_item_type():
	return Item_Type
	
func set_item_type(item_type):
	Item_Type = item_type
	
func get_object():
	return cloned_item
	
