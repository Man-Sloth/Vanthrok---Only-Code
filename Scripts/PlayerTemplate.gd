extends CharacterBody2D

#placeholder projectile
const MALE_NORMAL_MODE = preload("res://Assets/SpriteFrames/Paperdolling/Male_Normal_Mode.tres")
const MALE_ATTACK_MODE = preload("res://Assets/SpriteFrames/Paperdolling/Male_Attack_Mode.tres")
const BLANK_TEMPLATE = preload("res://Assets/SpriteFrames/Paperdolling/Cloth tier/BLANK_TEMPLATE.tres")

var normal_helmet = SpriteFrames.new()
var attack_helmet = SpriteFrames.new()
var normal_chest = SpriteFrames.new()
var attack_chest = SpriteFrames.new()
var normal_leggings = SpriteFrames.new()
var attack_leggings = SpriteFrames.new()
var normal_gauntlets = SpriteFrames.new()
var attack_gauntlets = SpriteFrames.new()
var normal_weapon = SpriteFrames.new()
var attack_weapon = SpriteFrames.new()
var normal_shield = SpriteFrames.new()
var attack_shield = SpriteFrames.new()

var globals_sprites_position = position

@onready var body_sprite = $"Body Sprite"
@onready var chest_sprite = $"Chest Sprite"
@onready var gauntlet_sprite = $"Gauntlet Sprite"
@onready var leggings_sprite = $"Leggings Sprite"
@onready var shield_sprite = $"Shield Sprite"
@onready var weapon_sprite = $"Weapon Sprite"
@onready var helmet_sprite = $"Helm Sprite"
@onready var shadow = $Shadow


enum dir {N, E, W, S, NE, SE, SW, NW}
var attack_dict = {} #to hold projectiles
var state = "Passive"
var is_attacking = false
var attack_time = 0.0
var facing = dir.S

func _physics_process(_delta):
	if is_attacking:
		Attack()
		
func Attack():
	
	if attack_time <= GameServer.client_clock:
		body_sprite.sprite_frames = MALE_ATTACK_MODE
		helmet_sprite.offset.y = -76
		chest_sprite.offset.y = -68
		chest_sprite.offset.x = -0
		leggings_sprite.offset.y = -23
		gauntlet_sprite.offset.y = -64
		weapon_sprite.offset.y = -57
		shield_sprite.offset.y = -68
		if facing == dir.S:
			body_sprite.play("Attacking_S")
			helmet_sprite.play("Attacking_S")
			chest_sprite.play("Attacking_S")
			gauntlet_sprite.play("Attacking_S")
			leggings_sprite.play("Attacking_S")
			weapon_sprite.play("Attacking_S")
			shield_sprite.play("Attacking_S")
		elif facing == dir.N:
			body_sprite.play("Attacking_N")
			helmet_sprite.play("Attacking_N")
			chest_sprite.play("Attacking_N")
			gauntlet_sprite.play("Attacking_N")
			leggings_sprite.play("Attacking_N")
			weapon_sprite.play("Attacking_N")
			shield_sprite.play("Attacking_N")
		elif facing == dir.W:
			body_sprite.play("Attacking_W")
			helmet_sprite.play("Attacking_W")
			chest_sprite.play("Attacking_W")
			gauntlet_sprite.play("Attacking_W")
			leggings_sprite.play("Attacking_W")
			weapon_sprite.play("Attacking_W")
			shield_sprite.play("Attacking_W")
		elif facing == dir.E:
			body_sprite.play("Attacking_E")
			helmet_sprite.play("Attacking_E")
			chest_sprite.play("Attacking_E")
			gauntlet_sprite.play("Attacking_E")
			leggings_sprite.play("Attacking_E")
			weapon_sprite.play("Attacking_E")
			shield_sprite.play("Attacking_E")
		elif facing == dir.NE:
			body_sprite.play("Attacking_NE")
			helmet_sprite.play("Attacking_NE")
			chest_sprite.play("Attacking_NE")
			gauntlet_sprite.play("Attacking_NE")
			leggings_sprite.play("Attacking_NE")
			weapon_sprite.play("Attacking_NE")
			shield_sprite.play("Attacking_NE")	
		elif facing == dir.SE:
			body_sprite.play("Attacking_SE")
			helmet_sprite.play("Attacking_SE")
			chest_sprite.play("Attacking_SE")
			gauntlet_sprite.play("Attacking_SE")
			leggings_sprite.play("Attacking_SE")
			weapon_sprite.play("Attacking_SE")
			shield_sprite.play("Attacking_SE")
		elif facing == dir.SW:	
			body_sprite.play("Attacking_SW")
			helmet_sprite.play("Attacking_SW")
			chest_sprite.play("Attacking_SW")
			gauntlet_sprite.play("Attacking_SW")
			leggings_sprite.play("Attacking_SW")
			weapon_sprite.play("Attacking_SW")
			shield_sprite.play("Attacking_SW")
		elif facing == dir.NW:
			body_sprite.play("Attacking_NW")
			helmet_sprite.play("Attacking_NW")
			chest_sprite.play("Attacking_NW")
			gauntlet_sprite.play("Attacking_NW")
			leggings_sprite.play("Attacking_NW")
			weapon_sprite.play("Attacking_NW")
			shield_sprite.play("Attacking_NW")

	var frameIndex: int = body_sprite.get_frame()
	var animationName: String = body_sprite.animation
	var spriteFrames: SpriteFrames = body_sprite.get_sprite_frames()
	shadow.texture = spriteFrames.get_frame_texture(animationName, frameIndex)

	shadow.offset.x = -20
	shadow.offset.y = -30
	shadow.skew = 150

	shadow.self_modulate = Color(0, 0, 0, .60)

func MovePlayer(new_position, new_facing, mode, equipment):
	
	if not is_attacking:
		var helm = false
		var chest = false
		var arm = false
		var leg = false
		var wep = false
		var shld = false
		if mode: #Not attack mode
			body_sprite.sprite_frames = MALE_ATTACK_MODE
			for e in equipment:
				if e == "H":
					attack_helmet = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Hat.tres")
					helmet_sprite.sprite_frames = attack_helmet
					helm = true
					helmet_sprite.offset.y = -115
				elif e == "C":
					attack_chest = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Shirt.tres")
					chest_sprite.sprite_frames = attack_chest
					chest = true
					chest_sprite.offset.y = -68
					chest_sprite.offset.x = -5
				elif e == "P":
					attack_leggings = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Pants.tres")
					leggings_sprite.sprite_frames = attack_leggings
					leg = true
					leggings_sprite.offset.y = -45
				elif e == "G":
					attack_gauntlets = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Gloves.tres")
					gauntlet_sprite.sprite_frames = attack_gauntlets
					arm = true
					gauntlet_sprite.offset.y = -43
				elif e == "W":
					attack_weapon = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Sword.tres")
					weapon_sprite.sprite_frames = attack_weapon
					wep = true
					weapon_sprite.offset.y = -107
				elif e == "S":
					attack_shield = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Attack_Shield.tres")
					shield_sprite.sprite_frames = attack_shield
					shld = true
					shield_sprite.offset.y = -73
					
		else:
			body_sprite.sprite_frames = MALE_NORMAL_MODE
			for e in equipment:
				if e == "H":
					normal_helmet = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Helmet.tres")
					helmet_sprite.sprite_frames = normal_helmet
					helm = true
					helmet_sprite.offset.y = -110
				elif e == "C":
					normal_chest = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Shirt.tres")
					chest_sprite.sprite_frames = normal_chest
					chest = true
					chest_sprite.offset.y = -67
					chest_sprite.offset.x = -4
				elif e == "P":
					normal_leggings = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Pants.tres")
					leggings_sprite.sprite_frames = normal_leggings
					leg = true
					leggings_sprite.offset.y = -41
				elif e == "G":
					normal_gauntlets = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Gloves.tres")
					gauntlet_sprite.sprite_frames = normal_gauntlets
					arm = true
					gauntlet_sprite.offset.y = -43
				elif e == "W":
					normal_weapon = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Sword.tres")
					weapon_sprite.sprite_frames = normal_weapon
					wep = true
					weapon_sprite.offset.y = -43
					
				elif e == "S":
					normal_shield = load("res://Assets/SpriteFrames/Paperdolling/Cloth tier/Human_Shield.tres")
					shield_sprite.sprite_frames = normal_shield
					shld = true
					shield_sprite.offset.y = -49
					
		
		if ! helm:
			helmet_sprite.sprite_frames = BLANK_TEMPLATE
		if ! chest:
			chest_sprite.sprite_frames = BLANK_TEMPLATE
		if ! arm:
			gauntlet_sprite.sprite_frames = BLANK_TEMPLATE
		if ! leg:
			leggings_sprite.sprite_frames = BLANK_TEMPLATE
		if ! wep:
			weapon_sprite.sprite_frames = BLANK_TEMPLATE
		if ! shld:
			shield_sprite.sprite_frames = BLANK_TEMPLATE
			
			
					
		if new_position == position: # Standing still
			if new_facing == dir.S:
				body_sprite.play("idle_down")
				helmet_sprite.play("idle_south")
				chest_sprite.play("idle_south")
				gauntlet_sprite.play("idle_south")
				leggings_sprite.play("idle_south")
				weapon_sprite.play("idle_south")
				shield_sprite.play("idle_south")
			elif new_facing == dir.N:
				body_sprite.play("idle_up")
				helmet_sprite.play("idle_north")
				chest_sprite.play("idle_north")
				gauntlet_sprite.play("idle_north")
				leggings_sprite.play("idle_north")
				weapon_sprite.play("idle_north")
				shield_sprite.play("idle_north")
			elif new_facing == dir.W:
				body_sprite.play("idle_left")
				helmet_sprite.play("idle_west")
				chest_sprite.play("idle_west")
				gauntlet_sprite.play("idle_west")
				leggings_sprite.play("idle_west")
				weapon_sprite.play("idle_west")
				shield_sprite.play("idle_west")
			elif new_facing == dir.E:
				body_sprite.play("idle_right")
				helmet_sprite.play("idle_east")
				chest_sprite.play("idle_east")
				gauntlet_sprite.play("idle_east")
				leggings_sprite.play("idle_east")
				weapon_sprite.play("idle_east")
				shield_sprite.play("idle_east")
			elif new_facing == dir.NE:
				body_sprite.play("idle_NE")	
				helmet_sprite.play("idle_NE")
				chest_sprite.play("idle_NE")
				gauntlet_sprite.play("idle_NE")
				leggings_sprite.play("idle_NE")
				weapon_sprite.play("idle_NE")
				shield_sprite.play("idle_NE")
			elif new_facing == dir.SE:
				body_sprite.play("idle_SE")
				helmet_sprite.play("idle_SE")
				chest_sprite.play("idle_SE")
				gauntlet_sprite.play("idle_SE")
				leggings_sprite.play("idle_SE")
				weapon_sprite.play("idle_SE")
				shield_sprite.play("idle_SE")
			elif new_facing == dir.SW:	
				body_sprite.play("idle_SW")
				helmet_sprite.play("idle_SW")
				chest_sprite.play("idle_SW")
				gauntlet_sprite.play("idle_SW")
				leggings_sprite.play("idle_SW")
				weapon_sprite.play("idle_SW")
				shield_sprite.play("idle_SW")
			elif new_facing == dir.NW:
				body_sprite.play("idle_NW")
				helmet_sprite.play("idle_NW")
				chest_sprite.play("idle_NW")
				gauntlet_sprite.play("idle_NW")
				leggings_sprite.play("idle_NW")
				weapon_sprite.play("idle_NW")
				shield_sprite.play("idle_NW")
		else: # Walking
			if new_facing == dir.S:
				body_sprite.play("walk_down")	
				helmet_sprite.play("walk_south")
				chest_sprite.play("walk_south")
				gauntlet_sprite.play("walk_south")
				leggings_sprite.play("walk_south")
				weapon_sprite.play("walk_south")
				shield_sprite.play("walk_south")
			elif new_facing == dir.N:	
				body_sprite.play("walk_up")	
				helmet_sprite.play("walk_north")
				chest_sprite.play("walk_north")
				gauntlet_sprite.play("walk_north")
				leggings_sprite.play("walk_north")
				weapon_sprite.play("walk_north")
				shield_sprite.play("walk_north")
			elif new_facing == dir.W:
				body_sprite.play("walk_left")
				helmet_sprite.play("walk_west")
				chest_sprite.play("walk_west")
				gauntlet_sprite.play("walk_west")
				leggings_sprite.play("walk_west")
				weapon_sprite.play("walk_west")
				shield_sprite.play("walk_west")	
			elif new_facing == dir.E:
				body_sprite.play("walk_right")	
				helmet_sprite.play("walk_east")
				chest_sprite.play("walk_east")
				gauntlet_sprite.play("walk_east")
				leggings_sprite.play("walk_east")
				weapon_sprite.play("walk_east")
				shield_sprite.play("walk_east")
			elif new_facing == dir.NE:
				body_sprite.play("walk_NE")	
				helmet_sprite.play("walk_NE")
				chest_sprite.play("walk_NE")
				gauntlet_sprite.play("walk_NE")
				leggings_sprite.play("walk_NE")
				weapon_sprite.play("walk_NE")
				shield_sprite.play("walk_NE")
			elif new_facing == dir.SE:	
				body_sprite.play("walk_SE")	
				helmet_sprite.play("walk_SE")
				chest_sprite.play("walk_SE")
				gauntlet_sprite.play("walk_SE")
				leggings_sprite.play("walk_SE")
				weapon_sprite.play("walk_SE")
				shield_sprite.play("walk_SE")
			elif new_facing == dir.SW:	
				body_sprite.play("walk_SW")	
				helmet_sprite.play("walk_SW")
				chest_sprite.play("walk_SW")
				gauntlet_sprite.play("walk_SW")
				leggings_sprite.play("walk_SW")
				weapon_sprite.play("walk_SW")
				shield_sprite.play("walk_SW")
			elif new_facing == dir.NW:
				body_sprite.play("walk_NW")	
				helmet_sprite.play("walk_NW")
				chest_sprite.play("walk_NW")
				gauntlet_sprite.play("walk_NW")
				leggings_sprite.play("walk_NW")
				weapon_sprite.play("walk_NW")
				shield_sprite.play("walk_NW")
	
	set_position(new_position)
	var frameIndex: int = body_sprite.get_frame()
	var animationName: String = body_sprite.animation
	var spriteFrames: SpriteFrames = body_sprite.get_sprite_frames()
	shadow.texture = spriteFrames.get_frame_texture(animationName, frameIndex)

	shadow.offset.x = -20
	shadow.offset.y = -30
	shadow.skew = 150

	shadow.self_modulate = Color(0, 0, 0, .60)

func _on_body_sprite_animation_finished():
	is_attacking = false
	body_sprite.sprite_frames = MALE_ATTACK_MODE
