extends CharacterBody2D

@onready var body_sprite = $"Body Sprite"
@onready var chest_sprite = $"Chest Sprite"
@onready var leggings_sprite = $"Leggings Sprite"
@onready var helmet_sprite = $"Helm Sprite"
@onready var gauntlet_sprite = $"Gauntlet Sprite"
@onready var weapon_sprite = $"Weapon Sprite"
@onready var shield_sprite = $"Shield Sprite"
@onready var swing_timer = $SwingTimer
@onready var shadow = $Shadow


var focused_enemy = null

var globals_sprites_position = position
var new_animation

const MALE_NORMAL_MODE = preload("res://Assets/SpriteFrames/Paperdolling/Male_Normal_Mode.tres")
const MALE_ATTACK_MODE = preload("res://Assets/SpriteFrames/Paperdolling/Male_Attack_Mode.tres")
const BLANK_ANIMATION = preload("res://Assets/SpriteFrames/Paperdolling/Cloth tier/BLANK_TEMPLATE.tres")

var hat_normal = SpriteFrames.new()
var hat_attack = SpriteFrames.new()
var shirt_normal = SpriteFrames.new()
var shirt_attack = SpriteFrames.new()
var glove_normal = SpriteFrames.new()
var glove_attack = SpriteFrames.new()
var pants_normal = SpriteFrames.new()
var pants_attack = SpriteFrames.new()
var weapon_normal = SpriteFrames.new()
var weapon_attack = SpriteFrames.new()
var shield_normal = SpriteFrames.new()
var shield_attack = SpriteFrames.new()


var hat_on = false
var shirt_on = false
var pants_on = false
var gloves_on = false
var weapon_on = false
var shield_on = false
var attack_finished = true

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
var can_stop_mouse = false
var directionX
var directionY
enum dir {N, E, W, S, NE, SE, SW, NW}
var facing = dir.S
var attack_facing = dir.S
var last_facing = null


var currentFrame = 0
var currentAnimation = "idle_down"
enum armorslot {HELM, GAUNTLET, SHIELD, LEGGINGS, WEAPON, CHEST}
enum armor_mat {CLOTH} 
var shirt_type = -1

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
	set_physics_process(true)
	
		

func _process(delta):
	pass
	#Server.FetchPlayerStats("Player Stats", get_instance_id())
	
	
	
	if get_attack_mode():
		GameManager.set_attack_cursor(true)
	else:
		GameManager.set_attack_cursor(false)
	
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
		shadow.position = new_position
		
	else:
		globals_sprites_position = global_position
		
func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	if !Input.is_action_pressed("move_to_mouse"):
		directionX = Input.get_axis("move_left", "move_right")
		directionY = Input.get_axis("move_up", "move_down")
		var dirNormed = Vector2(256*directionX, 128*directionY).normalized()
		directionX = dirNormed.x
		directionY = dirNormed.y
	
	if Input.is_action_pressed("move_to_mouse"):
		var direction = (get_global_mouse_position() - self.position)
		if direction.length() <= 15:
			can_stop_mouse = true
		elif direction.length() > 100:
			can_stop_mouse = false

		if can_stop_mouse:
			directionX = 0
			directionY = 0
		else:
			direction = direction.normalized()
			directionX = direction.x
			directionY = direction.y
		
	
	find_facing()
	Animate()
	
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
	
func load_resource(path):
	new_animation = load(path)

func set_frames(object):
	if object.get_item_type() == 1:
		shirt_normal = object.get_frames()
		shirt_attack = object.get_attack_frames()
		if !attack_mode:
			chest_sprite.sprite_frames = shirt_normal
		else:
			chest_sprite.sprite_frames = shirt_attack
		chest_sprite.visible = true
	elif object.get_item_type() == 0:
		hat_normal = object.get_frames()
		hat_attack = object.get_attack_frames()
		if !attack_mode:
			helmet_sprite.sprite_frames = hat_normal
		else:
			helmet_sprite.sprite_frames = hat_attack
		helmet_sprite.visible = true 
	elif object.get_item_type() == 2:
		pants_normal = object.get_frames()
		pants_attack = object.get_attack_frames()
		if !attack_mode:
			leggings_sprite.sprite_frames = pants_normal
		else:
			leggings_sprite.sprite_frames = pants_attack
		leggings_sprite.visible = true
	elif object.get_item_type() == 3:
		glove_normal = object.get_frames()
		glove_attack = object.get_attack_frames()
		if !attack_mode:
			gauntlet_sprite.sprite_frames = glove_normal
		else:
			gauntlet_sprite.sprite_frames = glove_attack
		gauntlet_sprite.visible = true 
	elif object.get_item_type() == 4:
		weapon_normal = object.get_frames()
		weapon_attack = object.get_attack_frames()
		if !attack_mode:
			weapon_sprite.sprite_frames = weapon_normal
		else:
			weapon_sprite.sprite_frames = weapon_attack
		weapon_sprite.visible = true 
	elif object.get_item_type() == 5:
		shield_normal = object.get_frames()
		shield_attack = object.get_attack_frames()
		if !attack_mode:
			shield_sprite.sprite_frames = shield_normal
		else:
			shield_sprite.sprite_frames = shield_attack
	
func clear_spriteframes(armor):
	if armor == 0:
		helmet_sprite.sprite_frames = BLANK_ANIMATION
	elif armor == 1:
		chest_sprite.sprite_frames = BLANK_ANIMATION
	elif armor == 2:
		leggings_sprite.sprite_frames = BLANK_ANIMATION
	elif armor == 3:
		gauntlet_sprite.sprite_frames = BLANK_ANIMATION
	elif armor == 4:
		weapon_sprite.sprite_frames = BLANK_ANIMATION
	elif armor == 5:
		shield_sprite.sprite_frames = BLANK_ANIMATION

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
	in_battle = battle
	
func set_focused(enemy):
	focused_enemy = enemy

func DefinePlayerState():
	var equipment = []
	if hat_on:
		equipment.append("H")
	if shirt_on:
		equipment.append("C")
	if pants_on:
		equipment.append("P")
	if gloves_on:
		equipment.append("G")
	if weapon_on:
		equipment.append("W")
	if shield_on:
		equipment.append("S")
	
	
	player_state = {"T": GameServer.client_clock, "P": get_global_position(), "A": facing, "M": attack_mode, "Q": equipment}
	GameServer.SendPlayerState(player_state)
	
func Animate():
	
	if(!attacking):
		if attack_finished && attack_mode:
			weapon_sprite.offset.y = -101
			shield_sprite.offset.y = -68
			helmet_sprite.offset.y = -110
			leggings_sprite.offset.y = -40
			gauntlet_sprite.offset.y = -38
			chest_sprite.offset.x = -10
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
					GameServer.NPCHit(GameManager.get_target().to_int(), "P")
					damage_frame = true				
		
	if Input.is_action_just_released("attack_mode"):
		attack_released = true
	
	if attack_released:
		attack_released = false
		
		if attack_mode:
			stop_attacking()
			attack_mode = false
			body_sprite.sprite_frames = MALE_NORMAL_MODE
			if hat_on:
				helmet_sprite.sprite_frames = hat_normal
				helmet_sprite.offset.y = -110
			else:
				helmet_sprite.sprite_frames = BLANK_ANIMATION
				
			if shirt_on:	
				chest_sprite.sprite_frames = shirt_normal
				chest_sprite.offset.x = -10
			else:
				chest_sprite.sprite_frames = BLANK_ANIMATION
				
			if gloves_on:
				gauntlet_sprite.sprite_frames = glove_normal
			else:
				gauntlet_sprite.sprite_frames = BLANK_ANIMATION
				
			if pants_on:
				leggings_sprite.sprite_frames = pants_normal
				leggings_sprite.offset.y = -37
			else:
				leggings_sprite.sprite_frames = BLANK_ANIMATION
			if weapon_on:
				weapon_sprite.sprite_frames = weapon_normal
				weapon_sprite.offset.y = -38
			else:
				weapon_sprite.sprite_frames = BLANK_ANIMATION
			if shield_on:
				shield_sprite.sprite_frames = shield_normal
				shield_sprite.offset.y = -41
			else:
				shield_sprite.sprite_frames = BLANK_ANIMATION
		else:
			attack_mode = true
			body_sprite.sprite_frames = MALE_ATTACK_MODE
			
			if hat_on:
				helmet_sprite.sprite_frames = hat_attack
				helmet_sprite.offset.y = -110
			else:
				helmet_sprite.sprite_frames = BLANK_ANIMATION
				
			if shirt_on:
				chest_sprite.sprite_frames = shirt_attack
				chest_sprite.offset.x = -10
			else:
				chest_sprite.sprite_frames = BLANK_ANIMATION
				
			if gloves_on:
				gauntlet_sprite.sprite_frames = glove_attack
			else:
				gauntlet_sprite.sprite_frames = BLANK_ANIMATION
				
			if pants_on:
				leggings_sprite.sprite_frames = pants_attack
				leggings_sprite.offset.y = -40
			else:
				leggings_sprite.sprite_frames = BLANK_ANIMATION
			if weapon_on:
				weapon_sprite.sprite_frames = weapon_attack
				weapon_sprite.offset.y = -101
			else:
				weapon_sprite.sprite_frames = BLANK_ANIMATION
			if shield_on:
				shield_sprite.sprite_frames = shield_attack
				shield_sprite.offset.y = -68
			else:
				shield_sprite.sprite_frames = BLANK_ANIMATION	
				
		

	var frameIndex: int = body_sprite.get_frame()
	var animationName: String = body_sprite.animation
	var spriteFrames: SpriteFrames = body_sprite.get_sprite_frames()
	shadow.texture = spriteFrames.get_frame_texture(animationName, frameIndex)

	var size = 1.2
	shadow.offset.x = -20
	shadow.offset.y = -30
	shadow.skew = -20
	shadow.scale.x = size
	shadow.scale.y = size
	

	shadow.self_modulate = Color(0, 0, 0, .60)
		
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

func apply_damage():
	return damage

func _on_swing_timer_timeout():
	GameServer.SendAttack(facing)
	attacking = true
	weapon_sprite.offset.y = -52
	shield_sprite.offset.y = -55
	helmet_sprite.offset.y = -71
	leggings_sprite.offset.y = -17
	gauntlet_sprite.offset.y = -59
	chest_sprite.offset.x = -5
	attack_finished = false
	if attack_facing == dir.S:
		body_sprite.play("Attacking_S")
		weapon_sprite.play("Attacking_S")
		shield_sprite.play("Attacking_S")
		helmet_sprite.play("Attacking_S")
		leggings_sprite.play("Attacking_S")
		gauntlet_sprite.play("Attacking_S")
		chest_sprite.play("Attacking_S")
		facing = dir.S
	elif attack_facing == dir.N:
		body_sprite.play("Attacking_N")
		weapon_sprite.play("Attacking_N")
		shield_sprite.play("Attacking_N")
		helmet_sprite.play("Attacking_N")
		leggings_sprite.play("Attacking_N")
		gauntlet_sprite.play("Attacking_N")
		chest_sprite.play("Attacking_N")
		facing = dir.N
	elif attack_facing == dir.E:
		body_sprite.play("Attacking_E")
		weapon_sprite.play("Attacking_E")
		shield_sprite.play("Attacking_E")
		helmet_sprite.play("Attacking_E")
		leggings_sprite.play("Attacking_E")
		gauntlet_sprite.play("Attacking_E")
		chest_sprite.play("Attacking_E")
		facing = dir.E
	elif attack_facing == dir.W:
		body_sprite.play("Attacking_W")
		weapon_sprite.play("Attacking_W")
		shield_sprite.play("Attacking_W")
		helmet_sprite.play("Attacking_W")
		leggings_sprite.play("Attacking_W")
		gauntlet_sprite.play("Attacking_W")
		chest_sprite.play("Attacking_W")
		facing = dir.W
	elif attack_facing == dir.NE:
		body_sprite.play("Attacking_NE")
		weapon_sprite.play("Attacking_NE")
		shield_sprite.play("Attacking_NE")
		helmet_sprite.play("Attacking_NE")
		leggings_sprite.play("Attacking_NE")
		gauntlet_sprite.play("Attacking_NE")
		chest_sprite.play("Attacking_NE")
		facing = dir.NE
	elif attack_facing == dir.NW:
		body_sprite.play("Attacking_NW")
		weapon_sprite.play("Attacking_NW")
		shield_sprite.play("Attacking_NW")
		helmet_sprite.play("Attacking_NW")
		leggings_sprite.play("Attacking_NW")
		gauntlet_sprite.play("Attacking_NW")
		chest_sprite.play("Attacking_NW")
		facing = dir.NW
	elif attack_facing == dir.SE:
		body_sprite.play("Attacking_SE")
		weapon_sprite.play("Attacking_SE")
		shield_sprite.play("Attacking_SE")
		helmet_sprite.play("Attacking_SE")
		leggings_sprite.play("Attacking_SE")
		gauntlet_sprite.play("Attacking_SE")
		chest_sprite.play("Attacking_SE")
		facing = dir.SE
	elif attack_facing == dir.SW:
		body_sprite.play("Attacking_SW")
		weapon_sprite.play("Attacking_SW")
		shield_sprite.play("Attacking_SW")	
		helmet_sprite.play("Attacking_SW")
		leggings_sprite.play("Attacking_SW")
		gauntlet_sprite.play("Attacking_SW")
		chest_sprite.play("Attacking_SW")
		facing = dir.SW
	
func _on_body_sprite_animation_finished():
	attacking = false
	damage_frame = false
	attack_finished = true
