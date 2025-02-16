extends CharacterBody2D

@onready var body_sprite = $"Body Sprite"
@onready var chest_sprite = $"Chest Sprite"
@onready var leggings_sprite = $"Leggings Sprite"
@onready var helmet_sprite = $"Helm Sprite"
@onready var gauntlet_sprite = $"Gauntlet Sprite"
@onready var weapon_sprite = $"Weapon Sprite"
@onready var shield_sprite = $"Shield Sprite"
@onready var swing_timer = $SwingTimer

var focused_enemy = null

var globals_sprites_position = position
var new_animation

const MALE_NORMAL_MODE = preload("res://Assets/sprites/SpriteFrames/Male_Normal_Mode.tres")
const MALE_ATTACK_MODE = preload("res://Assets/sprites/SpriteFrames/Male_Attack_Mode.tres")
@onready var shadow = $Shadow

var speed = 25000
var damage = 0
var player_state
var idle = false
var attack_mode = false
var attack_released = false
var attacking = false
var in_battle = false
var physics_call = false
var damage_frame = false
var directionX
var directionY
enum dir {N, E, W, S, NE, SE, SW, NW}
var facing = dir.S
var attack_facing = dir.S

var currentFrame = 0
var currentAnimation = "idle_down"
enum armorslot {HELM, GAUNTLET, SHIELD, LEGGINGS, WEAPON, CHEST}
enum armor_mat {CLOTH} 
var shirt_type = -1

var helmet_type = armor_mat.CLOTH
var pants_type = armor_mat.CLOTH
var gloves_type = armor_mat.CLOTH
var weapon_type = armor_mat.CLOTH
var shield_type = armor_mat.CLOTH

var last_shirt_type = -1
var last_helmet_type = -1
var last_pants_type = -1
var last_gloves_type = -1
var last_weapon_type = -1
var last_shield_type = -1

#var load_shirt = false
var load_thread = Thread.new()

var loaded_animations = []

func _ready():
	set_physics_process(false)

func _process(delta):
	#Server.FetchPlayerStats("Player Stats", get_instance_id())
	
	if get_attack_mode():
		GameManager.set_attack_cursor(true)
	else:
		GameManager.set_attack_cursor(false)
			
	# Get the input direction and handle the movement/deceleration.
	directionX = Input.get_axis("move_left", "move_right")
	directionY = Input.get_axis("move_up", "move_down")
	var dirNormed = Vector2(256*directionX, 128*directionY).normalized()
	directionX = dirNormed.x
	directionY = dirNormed.y
	
	if Input.is_action_pressed("move_to_mouse"):
		var direction = (get_global_mouse_position() - self.position).normalized()
		directionX = direction.x
		directionY = direction.y

	find_facing()
	Animate()
	
	# Movement interpolation so it doesn't matter what physics ticks is set at
	# There won't be any Jitter from movement
	var FPS = Engine.get_frames_per_second()
	if FPS > Engine.physics_ticks_per_second:
		var lerp_interval = velocity / FPS
		var lerp_position = global_position + lerp_interval
		globals_sprites_position = globals_sprites_position.lerp(lerp_position, min(delta * 50,1))
		var new_position = globals_sprites_position - global_position
		shadow.position = new_position
		body_sprite.position = new_position
		chest_sprite.position = new_position
		leggings_sprite.position = new_position
		helmet_sprite.position = new_position
		gauntlet_sprite.position = new_position
		weapon_sprite.position = new_position
		shield_sprite.position = new_position
		
	else:
		globals_sprites_position = global_position
		
func _physics_process(delta):
	# Apply movement
	if directionX:
		velocity.x = directionX * speed * delta
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if directionY:
		velocity.y = directionY * speed * delta
	else:
		velocity.y = move_toward(velocity.y, 0, speed)
	
	
	DefinePlayerState()
	move_and_slide()
	
#func set_chest_type(type):
	#shirt_type = type

func start_load_thread(path, armor_type, item_type):
	load_thread.start(load_resource.bind([path, armor_type, item_type]))
	
func load_resource(path, armor_type, item_type):
	new_animation = load(path)

func set_frames(object):
	if object.get_item_type() == 1:
		chest_sprite.sprite_frames = object.get_frames().sprite_frames
		chest_sprite.visible = true
	elif object.get_item_type() == 0:
		helmet_sprite.sprite_frames = object.get_frames().sprite_frames
		helmet_sprite.visible = true 
	elif object.get_item_type() == 2:
		leggings_sprite.sprite_frames = object.get_frames().sprite_frames
		leggings_sprite.visible = true
	elif object.get_item_type() == 3:
		gauntlet_sprite.sprite_frames = object.get_frames().sprite_frames
		gauntlet_sprite.visible = true 
	elif object.get_item_type() == 4:
		weapon_sprite.sprite_frames = object.get_frames().sprite_frames
		weapon_sprite.visible = true 
	elif object.get_item_type() == 5:
		shield_sprite.sprite_frames = object.get_frames().sprite_frames
		shield_sprite.visible = true 
			
func add_animation(armor_type, item_type):
	var path
	if(armor_type == armor_mat.CLOTH):
		if item_type == 1: #Chest piece
			path = "res://Assets/sprites/SpriteFrames/Human_Shirt.tres"
		#elif item_type == 0: #Helm
			#path = "res://Assets/sprites/SpriteFrames/Human_Helmet.tres"
		#elif item_type == 2:
			#path = "res://Assets/sprites/SpriteFrames/Human_Pants.tres"
		#elif item_type == 3:
			#path = "res://Assets/sprites/SpriteFrames/Human_Pants.tres"
		#elif item_type == 4:
			#path = "res://Assets/sprites/SpriteFrames/Human_Pants.tres"
	if path != null:
		start_load_thread(path, armor_type, item_type)
		
func remove_animation(asset_path):
	loaded_animations.erase(asset_path)
	
func clear_spriteframes():
	chest_sprite.sprite_frames = null
	shirt_type = -1

func Set_Speed(player_speed):
	speed = player_speed

func get_attack_mode():
	return attack_mode
	
func start_attacking():
	in_battle = true
	swing_timer.start()

func stop_attacking():
	in_battle = false
	swing_timer.stop()

func get_attacking():
	return attacking

func get_in_battle():
	return in_battle

func set_in_battle(battle):
	reset_damage()
	in_battle = battle
	
func set_focused(enemy):
	focused_enemy = enemy

func DefinePlayerState():
	player_state = {"T": GameServer.client_clock, "P": get_global_position(), "A": facing, "M": attack_mode}
	GameServer.SendPlayerState(player_state)
	
func Animate():
	if(!attacking):
		if idle: # Standing still
			if facing == dir.S:
				chest_sprite.play("idle_south")
				helmet_sprite.play("idle_south")
				leggings_sprite.play("idle_south")
				gauntlet_sprite.play("idle_south")
				weapon_sprite.play("idle_south")
				shield_sprite.play("idle_south")	
				body_sprite.play("idle_down")
			elif facing == dir.N:
				chest_sprite.play("idle_north")
				helmet_sprite.play("idle_north")
				leggings_sprite.play("idle_north")
				gauntlet_sprite.play("idle_north")
				weapon_sprite.play("idle_north")
				shield_sprite.play("idle_north")	
				body_sprite.play("idle_up")
			elif facing == dir.W:
				chest_sprite.play("idle_west")
				helmet_sprite.play("idle_west")
				leggings_sprite.play("idle_west")
				gauntlet_sprite.play("idle_west")
				weapon_sprite.play("idle_west")
				shield_sprite.play("idle_west")	
				body_sprite.play("idle_left")
			elif facing == dir.E:
				chest_sprite.play("idle_east")
				helmet_sprite.play("idle_east")
				leggings_sprite.play("idle_east")
				gauntlet_sprite.play("idle_east")
				weapon_sprite.play("idle_east")
				shield_sprite.play("idle_east")	
				body_sprite.play("idle_right")
			elif facing == dir.NE:
				chest_sprite.play("idle_NE")
				helmet_sprite.play("idle_NE")
				leggings_sprite.play("idle_NE")
				gauntlet_sprite.play("idle_NE")
				weapon_sprite.play("idle_NE")
				shield_sprite.play("idle_NE")
				body_sprite.play("idle_NE")	
			elif facing == dir.SE:
				chest_sprite.play("idle_SE")
				helmet_sprite.play("idle_SE")
				leggings_sprite.play("idle_SE")
				gauntlet_sprite.play("idle_SE")
				weapon_sprite.play("idle_SE")
				shield_sprite.play("idle_SE")	
				body_sprite.play("idle_SE")
			elif facing == dir.SW:
				chest_sprite.play("idle_SW")
				helmet_sprite.play("idle_SW")
				leggings_sprite.play("idle_SW")
				gauntlet_sprite.play("idle_SW")
				weapon_sprite.play("idle_SW")
				shield_sprite.play("idle_SW")	
				body_sprite.play("idle_SW")
			elif facing == dir.NW:
				chest_sprite.play("idle_NW")
				helmet_sprite.play("idle_NW")
				leggings_sprite.play("idle_NW")
				gauntlet_sprite.play("idle_NW")
				weapon_sprite.play("idle_NW")
				shield_sprite.play("idle_NW")	
				body_sprite.play("idle_NW")
		else: # Walking
			if facing == dir.S:
				chest_sprite.play("walk_south")
				helmet_sprite.play("walk_south")
				leggings_sprite.play("walk_south")
				gauntlet_sprite.play("walk_south")
				weapon_sprite.play("walk_south")
				shield_sprite.play("walk_south")
				body_sprite.play("walk_down")	
			elif facing == dir.N:
				chest_sprite.play("walk_north")
				helmet_sprite.play("walk_north")
				leggings_sprite.play("walk_north")
				gauntlet_sprite.play("walk_north")
				weapon_sprite.play("walk_north")
				shield_sprite.play("walk_north")	
				body_sprite.play("walk_up")	
			elif facing == dir.W:
				chest_sprite.play("walk_west")
				helmet_sprite.play("walk_west")
				leggings_sprite.play("walk_west")
				gauntlet_sprite.play("walk_west")
				weapon_sprite.play("walk_west")
				shield_sprite.play("walk_west")	
				body_sprite.play("walk_left")	
			elif facing == dir.E:
				chest_sprite.play("walk_east")
				helmet_sprite.play("walk_east")
				leggings_sprite.play("walk_east")
				gauntlet_sprite.play("walk_east")
				weapon_sprite.play("walk_east")
				shield_sprite.play("walk_east")	
				body_sprite.play("walk_right")	
			elif facing == dir.NE:
				chest_sprite.play("walk_NE")
				helmet_sprite.play("walk_NE")
				leggings_sprite.play("walk_NE")
				gauntlet_sprite.play("walk_NE")
				weapon_sprite.play("walk_NE")
				shield_sprite.play("walk_NE")	
				body_sprite.play("walk_NE")	
			elif facing == dir.SE:
				chest_sprite.play("walk_SE")
				helmet_sprite.play("walk_SE")
				leggings_sprite.play("walk_SE")
				gauntlet_sprite.play("walk_SE")
				weapon_sprite.play("walk_SE")
				shield_sprite.play("walk_SE")	
				body_sprite.play("walk_SE")	
			elif facing == dir.SW:
				chest_sprite.play("walk_SW")
				helmet_sprite.play("walk_SW")
				leggings_sprite.play("walk_SW")
				gauntlet_sprite.play("walk_SW")
				weapon_sprite.play("walk_SW")
				shield_sprite.play("walk_SW")	
				body_sprite.play("walk_SW")	
			elif facing == dir.NW:
				chest_sprite.play("walk_NW")
				helmet_sprite.play("walk_NW")
				leggings_sprite.play("walk_NW")
				gauntlet_sprite.play("walk_NW")
				weapon_sprite.play("walk_NW")
				shield_sprite.play("walk_NW")	
				body_sprite.play("walk_NW")	
	
	else:
		
		# Damage Enemy 
		if !damage_frame:
			if attacking:
				if body_sprite.frame >=8:
					do_damage()
					damage_frame = true	
					
	chest_sprite.frame = body_sprite.frame
	helmet_sprite.frame = body_sprite.frame
	leggings_sprite.frame = body_sprite.frame
	gauntlet_sprite.frame = body_sprite.frame
	weapon_sprite.frame = body_sprite.frame
	shield_sprite.frame = body_sprite.frame
			

			
		
	if Input.is_action_just_released("attack_mode"):
		attack_released = true
	
	if attack_released:
		attack_released = false
		
		if attack_mode:
			stop_attacking()
			attack_mode = false
			body_sprite.sprite_frames = MALE_NORMAL_MODE
		else:
			attack_mode = true
			body_sprite.sprite_frames = MALE_ATTACK_MODE

		body_sprite.set_frame_and_progress(currentFrame, 0.0)
		
func find_facing():
	
	idle = false
	if directionX == 0 && directionY == 0:
		idle = true
	elif directionX > 0:
		if abs(abs(directionY) - directionX) < 0.5:
			if directionY > 0:
				facing = dir.SE
			else:
				facing = dir.NE
		elif directionX > abs(directionY):
			facing = dir.E	
		else:
			if directionY > 0:
				facing = dir.S
			else:
				facing = dir.N
	else:
		if abs(abs(directionY) - abs(directionX)) < 0.5:
			if directionY > 0:
				facing = dir.SW
			else:
				facing = dir.NW
		elif abs(directionX) > abs(directionY):
			facing = dir.W
		else:
			if directionY > 0:
				facing = dir.S
			else:
				facing = dir.N
	
	if focused_enemy != null:
		var attack_dir = (focused_enemy.position - position).normalized()
		if attack_dir.x > 0:
			if abs(abs(attack_dir.y) - attack_dir.x) < 0.5:
				if attack_dir.y > 0:
					attack_facing = dir.SE
					#facing = dir.SE
				else:
					attack_facing = dir.NE
					#facing = dir.NE
			elif attack_dir.x > abs(attack_dir.y):
				#facing = dir.E
				attack_facing = dir.E	
			else:
				if attack_dir.y > 0:
					#facing = dir.S
					attack_facing = dir.S
				else:
					#facing = dir.N
					attack_facing = dir.N
		else:
			if abs(abs(attack_dir.y) - abs(attack_dir.x)) < 0.5:
				if attack_dir.y > 0:
					#facing = dir.SW
					attack_facing = dir.SW
				else:
					#facing = dir.NW
					attack_facing = dir.NW
			elif abs(attack_dir.x) > abs(attack_dir.y):
				#facing = dir.W
				attack_facing = dir.W
			else:
				if attack_dir.y > 0:
					#facing = dir.S
					attack_facing = dir.S
				else:
					#facing = dir.N
					attack_facing = dir.N

func reset_damage():
	damage = 0

func do_damage():
	damage += 20

func apply_damage():
	return damage

func _on_swing_timer_timeout():
	GameServer.SendAttack(position, facing)
	attacking = true
	if attack_facing == dir.S:
		body_sprite.play("Attacking_S")
		facing = dir.S
	elif attack_facing == dir.N:
		body_sprite.play("Attacking_N")
		facing = dir.N
	elif attack_facing == dir.E:
		body_sprite.play("Attacking_E")
		facing = dir.E
	elif attack_facing == dir.W:
		body_sprite.play("Attacking_W")
		facing = dir.W
	elif attack_facing == dir.NE:
		body_sprite.play("Attacking_NE")
		facing = dir.NE
	elif attack_facing == dir.NW:
		body_sprite.play("Attacking_NW")
		facing = dir.NW
	elif attack_facing == dir.SE:
		body_sprite.play("Attacking_SE")
		facing = dir.SE
	elif attack_facing == dir.SW:
		body_sprite.play("Attacking_SW")	
		facing = dir.SW
	
func _on_body_sprite_animation_finished():
	attacking = false
	damage_frame = false
