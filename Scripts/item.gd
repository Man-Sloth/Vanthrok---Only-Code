extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var player = $"/root/OmegaScene/Map/Player/"
var animated_sprite_2d
@onready var backpack = get_tree().get_root().get_node("OmegaScene/Map/CanvasLayer/Backpack")
@onready var char_window =get_tree().get_root().get_node("OmegaScene/Map/CanvasLayer/CharacterWindow")
var shadow
@export var tall = false
const SHADOW = preload("res://Assets/sprites/Characters/Player/Player_Shadow.png")

var item_tooltip
var name_title


@export_group("Item Properties")
enum ITEM_TYPE {Helm, Chest, Leggings, Gauntlets, Weapon, Shield, Stackable, Non_Stackable = -1}
@export var Item_Type: ITEM_TYPE
enum ARMOR_TYPE {CLOTH = -1}
@export var Armor_Type: ARMOR_TYPE
@export var tag = ""
var close_to_player = false
var mouse_hover = false
var holding = false
var object_animations = SpriteFrames.new()
var attack_animations = SpriteFrames.new()
var current_animations = SpriteFrames.new()
var dummy_image = Sprite2D.new()
@export var stack_size = 0
var inventory_slot = -1
var path = ""
var dummy_path = ""
var attack_path = ""

var item = {"visible": false, 
			"item_type": 0,
			"armor_type": 0,
			"path": "",
			"attack_path": "",
			"dummy_path": "",
			"dummy_sprite": null,
			"frames": null,
			"attack_frames": null,
			"stack_size": 0,
			"tag": ""}

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("init_stats")
	call_deferred("update_stats")
	
		
	#shadow.self_modulate = Color(0, 0, 0, .60)
func _process(_delta):
	if item_tooltip != null:
		if mouse_hover:
			item_tooltip.visible = true
		else:
			item_tooltip.visible = false
	
func _input(event):
	var holdOffset = Vector2(115,170)
	if close_to_player:
		if mouse_hover:
			if event.is_action_pressed("pickup"):
				holding = true
				GameManager.set_holding(true)
				GameManager.set_held_object(self)
				update_stats()
				GameManager.save_clone(load_clone())
				GameManager.set_ground_item(self)
				GameManager.set_held_position(event.position - holdOffset)		
				
func update_stats():
	
	if tag == "potion":
		animated_sprite_2d.play("red potion")
		name_title.text = "Potion: "+ str(stack_size)
	elif tag == "gold":
		animated_sprite_2d.play("gold")
		name_title.text = "Gold: " + str(stack_size)
	elif Armor_Type == 0: #cloth
		if Item_Type == ITEM_TYPE.Chest:
			animated_sprite_2d.play("cloth_chest")
			path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Shirt.tres"
			dummy_path = "res://Assets/sprites/Characters/Player/Paperdolling/Cloth/Cloth_Chest_South.tres"
			attack_path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Shirt.tres"
			name_title.text = "Field Shirt"
			#value = 3
			#weight = 2
		elif Item_Type == ITEM_TYPE.Helm:
			animated_sprite_2d.play("cloth_helm")
			path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Helmet.tres"
			dummy_path = "res://Assets/sprites/Characters/Player/Paperdolling/Cloth/Cloth_Head_South.tres"
			attack_path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Hat.tres"
			name_title.text = "Field Hat"
			#value = 2
			#weight = 1
		elif Item_Type == ITEM_TYPE.Gauntlets:
			animated_sprite_2d.play("cloth_arms")
			path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Gloves.tres"
			dummy_path = "res://Assets/sprites/Characters/Player/Paperdolling/Cloth/Cloth_Arms_South.tres"
			attack_path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Gloves.tres"
			name_title.text = "Field Gloves"
			#value = 1
			#weight = 1
		elif Item_Type == ITEM_TYPE.Leggings:
			animated_sprite_2d.play("cloth_pants")
			path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Pants.tres"
			dummy_path = "res://Assets/sprites/Characters/Player/Paperdolling/Cloth/Cloth_Legs_South.tres"
			attack_path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Pants.tres"
			name_title.text = "Field Pants"
			#value = 3
			#weight = 2
		elif Item_Type == ITEM_TYPE.Weapon:
			animated_sprite_2d.play("level1_sword")
			path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Sword.tres"
			dummy_path = "res://Assets/sprites/Characters/Player/Paperdolling/Cloth/DummySword.png"
			attack_path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Sword.tres"
			name_title.text = "Rusty Sword"
			#value = 7
			#weight = 5
		elif Item_Type == ITEM_TYPE.Shield:
			animated_sprite_2d.play("level1_shield")
			path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Shield.tres"
			dummy_path = "res://Assets/sprites/Characters/Player/Paperdolling/Cloth/Level1_Shield_South.tres"
			attack_path = "res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Shield.tres"
			name_title.text = "Buckler"
			#value = 6
			#weight = 8
			
	var frameIndex: int = animated_sprite_2d.get_frame()
	var animationName: String = animated_sprite_2d.animation
	var spriteFrames: SpriteFrames = animated_sprite_2d.get_sprite_frames()
	shadow.texture = spriteFrames.get_frame_texture(animationName, frameIndex)
	if tall:
		shadow.offset.x = -5
		shadow.offset.y -= 25
		shadow.skew = -20
		shadow.rotation = 0
		shadow.scale = Vector2(1, .75)
	else:
		shadow.offset.x = -10
		shadow.offset.y = -25
		shadow.scale = Vector2(.50, .50)
		
func load_clone():
	item["visible"] = false
	item["item_type"] = Item_Type
	item["armor_type"] = Armor_Type
	item["path"] = path
	item["attack_path"] = attack_path
	item["dummy_path"] = dummy_path
	item["dummy_sprite"] = dummy_image
	item["frames"] = object_animations
	item["attack_frames"] = attack_animations
	item["stack_size"] = stack_size
	item["tag"] = tag
	
	return item
	
func save_clone(new_item):
	visible = new_item["visible"]
	Item_Type = new_item["item_type"]
	Armor_Type = new_item["armor_type"]
	path = new_item["path"]
	attack_path = new_item["attack_path"]
	dummy_path = new_item["dummy_path"] 
	dummy_image = new_item["dummy_sprite"]
	object_animations = new_item["frames"]	
	attack_animations = new_item["attack_frames"]
	stack_size = new_item["stack_size"]
	tag = new_item["tag"]
			
func get_item_type():
	return Item_Type
	
func set_item_type(type):
	Item_Type = type
	
func get_armor_type():
	return Armor_Type

func set_armor_type(armorT):
	Armor_Type = armorT
	
func get_inventory_slot():
	return inventory_slot
	
func set_inventory_slot(slot_number):
	inventory_slot = slot_number
	
func _on_body_entered(body):
	if body == player:
		close_to_player = true

func _on_body_exited(body):
	if body == player:
		close_to_player = false
	
func _on_mouse_entered():
	
	mouse_hover = true
	GameManager.mouse_over_count +=1
	#GameManager.set_item_hovered(true)

func _on_mouse_exited():
	mouse_hover = false
	GameManager.mouse_over_count -=1
	#GameManager.set_item_hovered(false)
	
func delete():
	queue_free()

func get_resource_path():
	return path

func set_resource_path(new_path):
	path = new_path
	
func get_dummy_path():
	return dummy_path
	
func set_dummy_path(new_path):
	dummy_path = new_path
	
func get_attack_path():
	return attack_path

func set_attack_path(new_path):
	attack_path = new_path
	
func get_frames():
	return object_animations

func set_frames(new_animation):
	object_animations = new_animation

func get_attack_frames():
	return attack_animations
	
func set_attack_frames(new_anim):
	attack_animations = new_anim
	
func get_current_frames():
	return current_animations
	
func set_current_frames(curframe):
	current_animations = curframe

func get_dummy():
	return dummy_image
	
func set_dummy(new_dummy):
	dummy_image = new_dummy

func load_animations():
	return load(path)

func get_animation():
	return animated_sprite_2d.animation
	
func set_animation(new_animation):
	animated_sprite_2d.animation = new_animation

func get_visibility():
	return visible

func set_visibility(new_visible):
	visible = new_visible

func combine_stacks(added_value):
	stack_size += added_value

func get_stack_value():
	return stack_size
	


func _on_animated_sprite_2d_ready():
	animated_sprite_2d = $AnimatedSprite2D
	shadow = $shadow
	
func _on_name_ready():
	name_title = $ToolTip/PanelContainer/MarginContainer/Name
	item_tooltip = $ToolTip
	update_stats()

func init_stats():
	item_tooltip = $"ItemTooltip"
	name_title = $ItemTooltip/PanelContainer/MarginContainer/Name

	
