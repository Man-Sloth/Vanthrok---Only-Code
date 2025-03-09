extends TextureRect


@onready var item_sprite = $item_sprite
@onready var player = $"../../../../../../Player"
@onready var map = $"../../../../../../../Map"
@onready var inventory_slots = $".."
@onready var label

# Tooltip variables
var item_tooltip
var name_title
var value
var weight
var stats
var small_stats



@export_group("Item Properties")
enum ITEM_TYPE {Helm, Chest, Legs, Arms, Weapon, Shield, Stackable, Non_Stackable, Empty = -1}
@export var Item_Type: ITEM_TYPE
const OBJECTSCENE = preload("res://Scenes/Objects/item.tscn")
var holdOffset = Vector2(115,170)
enum armor_mat {CLOTH} 
var hovering = false
var object = null
var loaded_animation = AnimatedSprite2D.new()
var loaded_attack_anim = AnimatedSprite2D.new()
var dummy_image = Sprite2D.new()
var load_thread = Thread.new()
var stack_size = 0
var cloned_item = null
var clone = {}
var loaded_animations = {"normal_frames": SpriteFrames.new(), "attack_frames": SpriteFrames.new(), "dummy_sprite": AtlasTexture.new()}
#var new_animation = load("res://Assets/sprites/SpriteFrames/Human_BLANK.tres")

func _ready():
	call_deferred("init_stats")
	#print(item_tooltip.scene_file_path)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	show_tooltip()
	animate()
	
func _input(event):
	if hovering && GameManager.get_held_object() != null : #drop item into slot
		if event.is_action_released("pickup"):
			GameManager.last_container = ""
			object = GameManager.get_held_object()
			if cloned_item == null: # Drop into empty slot
				var object_dict = object.load_clone()
				GameManager.save_clone(object_dict)
				save_clone(GameManager.get_clone())
				add_animation(clone)
				if object.get_item_type() == ITEM_TYPE.Stackable:
					stack_size = object.stack_size
					get_node("item_sprite/Label").text = str(stack_size)
					get_node("item_sprite/Label").visible = true
				else:
					stack_size = 0
					get_node("item_sprite/Label").text = "0"
					get_node("item_sprite/Label").visible = false
				if GameManager.get_pulled_location()!= null and GameManager.get_pulled_location() != self:
					GameManager.get_pulled_location().get_node("item_sprite/Label").text = "0"
					GameManager.get_pulled_location().get_node("item_sprite/Label").visible = false
					GameManager.get_pulled_location().cloned_item = null
		
				#GameManager.delete_clone()
				object.delete()
				GameManager.clear()
				
			else: # Drop into a slot from the ground to a filled slot (Swap/stack)
				
				
				if GameManager.get_pulled_location() == null:
					GameManager.last_container = ""
					if cloned_item.get_item_type() == object.get_item_type() && cloned_item.get_item_type() == 6:
						cloned_item.stack_size += GameManager.get_held_object().stack_size
						if cloned_item.item["tag"] != "gold":
							if cloned_item.stack_size > 100:
								var remainder = cloned_item.stack_size % 100
								cloned_item.stack_size = 100
								get_node("item_sprite/Label").text = str(cloned_item.stack_size)
								for slot in inventory_slots.get_children():
									if slot.get_child(1) == null:
										slot.cloned_item = OBJECTSCENE.instantiate()
										slot.cloned_item.save_clone(object.load_clone())
										slot.cloned_item.stack_size = remainder
										slot.cloned_item.item["stack_size"] = remainder
										slot.add_child(slot.cloned_item)
										get_child(1).load_clone()
										slot.stack_size = remainder
										slot.get_node("item_sprite/Label").text = str(slot.stack_size)
										slot.get_node("item_sprite/Label").visible = true
										map.get_node("Items").remove_child(object)
										break
									#else:
										#if map.find_child(GameManager.get_held_object().name) != null:
											#map.find_child(GameManager.get_held_object().name).item["stack_size"] = remainder
							else:
								get_node("item_sprite/Label").text = str(cloned_item.stack_size)
								get_node("item_sprite/Label").visible = true
							
									
						else:
							get_node("item_sprite/Label").text = str(cloned_item.stack_size)	
						
						object.delete()
						GameManager.clear()	
									
					else:
						GameManager.get_held_object().load_clone()
						save_clone(GameManager.get_held_object().item)
						GameManager.add_clone()
						cloned_item.position = player.position
						remove_child(cloned_item)
						map.get_node("Items").add_child(cloned_item)
						cloned_item.visible = true
						add_animation(object)
						map.get_node("Items").remove_child(object)
						add_child(object)
						
						if object.get_item_type() != ITEM_TYPE.Stackable:
							get_node("item_sprite/Label").text = "0"
							get_node("item_sprite/Label").visible = false
						else:
							get_node("item_sprite/Label").text = str(object.load_clone()["stack_size"])
							get_node("item_sprite/Label").visible = true
						object.delete()
						GameManager.clear()
			
				else: # move from 1 filled slot to another filled slot (swap/stack)
					GameManager.last_container = ""
					if cloned_item.get_item_type() == GameManager.get_held_object().get_item_type() && cloned_item.get_item_type() == 6:
						cloned_item.stack_size += GameManager.get_held_object().stack_size
						if cloned_item.item["tag"] != "gold":
							if cloned_item.stack_size > 100:
								GameManager.get_pulled_location().clone["stack_size"] = cloned_item.stack_size % 100
								cloned_item.stack_size = 100
								GameManager.get_pulled_location().clone["tag"] =  cloned_item.item["tag"]
								get_node("item_sprite/Label").text = str(cloned_item.stack_size)
								
								GameManager.get_pulled_location().get_node("item_sprite/Label").visible = true
								GameManager.get_pulled_location().get_node("item_sprite/Label").text = str(GameManager.get_pulled_location().clone["stack_size"])
								GameManager.get_pulled_location().create_clone_item(GameManager.get_pulled_location().clone)
							else:
								cloned_item.load_clone()
								get_node("item_sprite/Label").text = str(clone["stack_size"])
								GameManager.last_pulled_from.cloned_item = null
								GameManager.last_pulled_from.get_node("item_sprite/Label").text = "0"
								GameManager.last_pulled_from.get_node("item_sprite/Label").visible = false	
						else:
							get_node("item_sprite/Label").text = str(cloned_item.stack_size)
					else:
						var tmp = cloned_item
						var tmp_clone = tmp.load_clone()
						
						var carried = GameManager.get_held_object().load_clone()
						create_clone_item(carried)
						GameManager.save_clone(tmp_clone)
						
						get_child(1).queue_free()
						GameManager.add_clone()
						clone = cloned_item.load_clone()
						
						if clone["item_type"] == ITEM_TYPE.Stackable:
							get_node("item_sprite/Label").text = str(clone["stack_size"])
							get_node("item_sprite/Label").visible = true	
							print("Right stacked")
						else:
							get_node("item_sprite/Label").text = "0"
							get_node("item_sprite/Label").visible = false
							print("Right non-stacked")
							
						var gm_clone = GameManager.get_clone()
						if gm_clone["item_type"] == ITEM_TYPE.Stackable:
							GameManager.last_pulled_from.get_node("item_sprite/Label").text = str(GameManager.get_clone()["stack_size"])
							GameManager.last_pulled_from.get_node("item_sprite/Label").visible = true	
							print("Left stacked")
						else:
							GameManager.last_pulled_from.get_node("item_sprite/Label").text = "0"
							GameManager.last_pulled_from.get_node("item_sprite/Label").visible = false
							print("Left non-stacked")

						
						
					GameManager.clear()
				
	elif hovering && GameManager.get_held_object() == null: #pick up item from slot

		if event.is_action_pressed("pickup"):
			if cloned_item != null:
				get_node("item_sprite/Label").text = "0"
				get_node("item_sprite/Label").visible = false
				GameManager.last_container = "Backpack"
				cloned_item.load_clone()
				cloned_item.item = clone
				GameManager.set_held_object(cloned_item)
				GameManager.save_clone(cloned_item.load_clone())
				GameManager.set_holding(true)
				GameManager.set_held_position(event.position - holdOffset)
				GameManager.set_pulled_location(self)
				remove_child(get_child(1))
				item_sprite.texture = null
				cloned_item = null
				
func save_clone(item):
	for key in item:
		clone[key] = item[key]
	
	
func send_clone():
	return cloned_item	

func create_clone_item(item):
	cloned_item = OBJECTSCENE.instantiate()
	cloned_item.visible = item["visible"]
	cloned_item.set_item_type(item["item_type"])
	cloned_item.set_armor_type(item["armor_type"])
	cloned_item.set_resource_path(item["path"])
	cloned_item.set_attack_path(item["attack_path"])
	cloned_item.set_dummy_path(item["dummy_path"]) 
	cloned_item.dummy_image = item["dummy_sprite"]
	cloned_item.object_animations = item["frames"]	
	cloned_item.attack_animations = item["attack_frames"]
	cloned_item.stack_size = item["stack_size"]
	cloned_item.tag = item["tag"]
	add_child(cloned_item)
	
func animate():
	if cloned_item != null:
		var animatedSprite2D = cloned_item.get_node("AnimatedSprite2D")
		var frameIndex: int = animatedSprite2D.get_frame()
		var animationName: String = animatedSprite2D.animation
		var spriteFrames: SpriteFrames = animatedSprite2D.get_sprite_frames()
		item_sprite.texture = spriteFrames.get_frame_texture(animationName, frameIndex)

func add_animation(new_clone):
	start_load_thread(new_clone["path"], new_clone["dummy_path"], new_clone["attack_path"])

func start_load_thread(path, dummy_path, attack_path):
	load_thread = Thread.new()
	load_thread.start(load_resource.bind(path, dummy_path, attack_path))
		
func load_resource(path, dummy_path, attack_path):
	var new_animation = AnimatedSprite2D.new()
	var new_attack_anim = AnimatedSprite2D.new()
	var new_dummy_image = Sprite2D.new()
	if path != "":
		new_animation.sprite_frames = load(path)
		new_dummy_image.texture = load(dummy_path)
		new_attack_anim.sprite_frames = load(attack_path)
	call_deferred("set_animation_frames", new_animation, new_dummy_image, new_attack_anim)
	
func set_animation_frames(new_animation, new_dummy_image, new_attack_anim):
	load_thread.wait_to_finish()
	loaded_animations["normal_frames"] = new_animation
	loaded_animations["attack_frames"] = new_attack_anim
	loaded_animations["dummy_sprite"] = new_dummy_image.texture
	
	cloned_item = OBJECTSCENE.instantiate()
	if clone != null:
		cloned_item.save_clone(clone)
	clone = cloned_item.load_clone()
	
	clone["frames"] = (loaded_animations["normal_frames"].sprite_frames)
	clone["attack_frames"] = (loaded_animations["attack_frames"].sprite_frames)
	clone["dummy_sprite"].texture = (loaded_animations["dummy_sprite"])
	
	cloned_item.set_frames(clone["frames"])
	cloned_item.set_attack_frames(clone["attack_frames"])
	cloned_item.set_dummy(clone["dummy_sprite"])	
	
	add_child(cloned_item)
	

		
func show_tooltip():
	if cloned_item != null:
		if hovering:
			name_title.text = cloned_item.name_title.text
			if cloned_item.item["item_type"] != 6:
				pass
				#value.text = "Value: " + str(cloned_item.value)
				#weight.text = "Weight: " + str(cloned_item.weight)
				#stack.text = "Stack: 0"
				#value.visible = true
				#weight.visible = true
				#stack.visible = false
			else:
				pass
				#stack.text = "Stack: " + str(cloned_item.item["stack_size"])
				#value.visible = false
				#weight.visible = false
				#stack.visible = true
			item_tooltip.visible = true
	#image 
	#description =
	#stack = 
	#name_title

func _on_mouse_entered():
	GameManager.set_hovering_slot(true)
	hovering = true

func _on_mouse_exited():
	GameManager.set_hovering_slot(false)
	hovering = false

func get_item_type():
	return Item_Type
	
func set_item_type(type):
	Item_Type = type
	
@warning_ignore("unused_parameter", "shadowed_variable")
func set_item_texture(clone):
	pass

func set_slot_object(new_object):
	cloned_item = new_object
	
func get_slot_object():
	return cloned_item

func init_stats():
	item_tooltip = $"../../../../ItemTooltip"
	name_title = $"../../../../ItemTooltip/NamePlate/MarginContainer/Name"
	#value = $"../../../../ItemTooltip/PanelContainer/MarginContainer/Value"
	#weight = $"../../../../ItemTooltip/PanelContainer/MarginContainer/Weight"
	#stats = $"../../../../ItemTooltip/PanelContainer/MarginContainer/Stats"
	#small_stats = $"../../../../ItemTooltip/PanelContainer/MarginContainer/Small Stats"
