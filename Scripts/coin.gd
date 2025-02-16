extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var backpack = get_tree().get_root().get_node("OmegaScene/Map/CanvasLayer/Backpack")
@onready var char_window =get_tree().get_root().get_node("OmegaScene/Map/CanvasLayer/CharacterWindow")

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
var dummy_image = Sprite2D.new()
var stack_size = 0
var inventory_slot = -1
var path = ""
var dummy_path = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	update_stats()

func _process(_delta):
	if mouse_hover:
		GameManager.set_item_hovered(true)
	
func _input(event):
	var holdOffset = Vector2(115,170)
	if close_to_player:
		if mouse_hover:
			if event.is_action_pressed("pickup"):
				holding = true
				GameManager.set_holding(true)
				GameManager.set_held_object(self)
				GameManager.set_ground_item(self)
				GameManager.set_held_position(event.position - holdOffset)		
				
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
	
func _on_body_entered(_body):
	close_to_player = true

func _on_body_exited(_body):
	close_to_player = false
	
func _on_mouse_entered():
	mouse_hover = true
	GameManager.set_item_hovered(true)

func _on_mouse_exited():
	mouse_hover = false
	GameManager.set_item_hovered(false)
	
func delete():
	queue_free()

func get_resource_path():
	return path

func set_resource_path(new_path):
	path = new_path
	
func get_dummy_path():
	return dummy_path
	
func get_frames():
	return object_animations

func set_frames(new_animation):
	object_animations = new_animation
	
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

func update_stats():
	if Armor_Type == 0: #cloth
		if Item_Type == ITEM_TYPE.Chest:
			animated_sprite_2d.play("cloth_chest")
			path = "res://Assets/sprites/SpriteFrames/Human_Shirt.tres"
			dummy_path = "res://Assets/sprites/Atlases/Small Sprites/Paperdolling/Cloth/Cloth_Chest_South.tres"
		elif Item_Type == ITEM_TYPE.Helm:
			animated_sprite_2d.play("cloth_helm")
			path = "res://Assets/sprites/SpriteFrames/Human_Helmet.tres"
			dummy_path = "res://Assets/sprites/Atlases/Small Sprites/Paperdolling/Cloth/Cloth_Head_South.tres"
		elif Item_Type == ITEM_TYPE.Gauntlets:
			animated_sprite_2d.play("cloth_arms")
			path = "res://Assets/sprites/SpriteFrames/Human_Gloves.tres"
			dummy_path = "res://Assets/sprites/Atlases/Small Sprites/Paperdolling/Cloth/Cloth_Arms_South.tres"
		elif Item_Type == ITEM_TYPE.Leggings:
			animated_sprite_2d.play("cloth_pants")
			path = "res://Assets/sprites/SpriteFrames/Human_Pants.tres"
			dummy_path = "res://Assets/sprites/Atlases/Small Sprites/Paperdolling/Cloth/Cloth_Legs_South.tres"
		elif Item_Type == ITEM_TYPE.Weapon:
			animated_sprite_2d.play("level1_sword")
			path = "res://Assets/sprites/SpriteFrames/Human_Sword.tres"
			dummy_path = "res://Assets/sprites/Atlases/Small Sprites/Paperdolling/Cloth/DummySword.png"
		elif Item_Type == ITEM_TYPE.Shield:
			animated_sprite_2d.play("level1_shield")
			path = "res://Assets/sprites/SpriteFrames/Human_Shield.tres"
			dummy_path = "res://Assets/sprites/Atlases/Small Sprites/Paperdolling/Cloth/Level1_Shield_South.tres"
	elif tag == "gold":
		pass


