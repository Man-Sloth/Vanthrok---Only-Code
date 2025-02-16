extends CharacterBody2D

#placeholder projectile
const ALIGNMENT_SELECTOR = preload("res://Assets/sprites/UI/AlignmentSelector.png")
const MALE_NORMAL_MODE = preload("res://Assets/sprites/SpriteFrames/Male_Normal_Mode.tres")
const MALE_ATTACK_MODE = preload("res://Assets/sprites/SpriteFrames/Male_Attack_Mode.tres")
@onready var body_sprite = $"Body Sprite"
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
	body_sprite.sprite_frames = MALE_ATTACK_MODE
	if is_attacking:
		if attack_time <= GameServer.client_clock:
			if facing == dir.S:
				body_sprite.play("Attacking_S")
			elif facing == dir.N:
				body_sprite.play("Attacking_N")
			elif facing == dir.W:
				body_sprite.play("Attacking_W")
			elif facing == dir.E:
				body_sprite.play("Attacking_E")
			elif facing == dir.NE:
				body_sprite.play("Attacking_NE")	
			elif facing == dir.SE:
				body_sprite.play("Attacking_SE")
			elif facing == dir.SW:	
				body_sprite.play("Attacking_SW")
			elif facing == dir.NW:
				body_sprite.play("Attacking_NW")



func MovePlayer(new_position, facing, mode):
	if not is_attacking:
		if mode: #Not attack mode
			body_sprite.sprite_frames = MALE_ATTACK_MODE
		else:
			body_sprite.sprite_frames = MALE_NORMAL_MODE
			
		if new_position == position: # Standing still
			if facing == dir.S:
				body_sprite.play("idle_down")
			elif facing == dir.N:
				body_sprite.play("idle_up")
			elif facing == dir.W:
				body_sprite.play("idle_left")
			elif facing == dir.E:
				body_sprite.play("idle_right")
			elif facing == dir.NE:
				body_sprite.play("idle_NE")	
			elif facing == dir.SE:
				body_sprite.play("idle_SE")
			elif facing == dir.SW:	
				body_sprite.play("idle_SW")
			elif facing == dir.NW:
				body_sprite.play("idle_NW")
		else: # Walking
			if facing == dir.S:
				body_sprite.play("walk_down")	
			elif facing == dir.N:	
				body_sprite.play("walk_up")	
			elif facing == dir.W:
				body_sprite.play("walk_left")	
			elif facing == dir.E:
				body_sprite.play("walk_right")	
			elif facing == dir.NE:
				body_sprite.play("walk_NE")	
			elif facing == dir.SE:	
				body_sprite.play("walk_SE")	
			elif facing == dir.SW:	
				body_sprite.play("walk_SW")	
			elif facing == dir.NW:
				body_sprite.play("walk_NW")	
	set_position(new_position)


func _on_body_sprite_animation_finished():
	is_attacking = false
	body_sprite.sprite_frames = MALE_NORMAL_MODE
