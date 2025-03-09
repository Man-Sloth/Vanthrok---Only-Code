extends CharacterBody2D

const speed = 10000

@export var player: Node2D = null
@onready var selected = $Selected
@onready var health_bar = $HealthBar
@onready var player_ref = $"../../Player"
@onready var body_sprite = $"Body Sprite"

var health = 100
var max_health = 100
var state
var type #currently not used

var hovering = false
var player_colliding = false
var attack_prev_frame = false
var clickable = true

# selector box variables
var default_scale = Vector2(0,0)
var max_scale = Vector2(0,0)
var select_growing = true
var grow_amount = 1.1

enum dir {N, E, W, S, NE, SE, SW, NW}
var facing = dir.S
var attack_time = 0.0
var is_attacking = false

func _ready() -> void:
	var percentage_hp = int((float(health) / max_health) * 100)
	health_bar.value = percentage_hp
	
	if state == "Idle":
		get_node("Body Sprite").play("idle_SE")
	elif state == "Dead":
		#get_node("AnimationPlayer").stop()
		get_node("Body Sprite").play("Dead")
		get_node("RigidBody2D/CollisionShape2D").set_deferred("disabled", true)
		get_node("SwingBody/CollisionShape2D").set_deferred("disabled", true)
		health_bar.hide()
		selected.hide()
		var timer = Timer.new()
		timer.wait_time = 10
		timer.autostart = true
		timer.timeout.connect(DeleteSelf)
		self.add_child(timer)
	
	set_physics_process(false)
	#makepath()
	default_scale = selected.scale
	max_scale = default_scale * 1.1

func Attack():
	if attack_time <= GameServer.client_clock:
		if facing == dir.S:
			body_sprite.play("Attack_S")
		elif facing == dir.N:
			body_sprite.play("Attack_N")
		elif facing == dir.W:
			body_sprite.play("Attack_W")
		elif facing == dir.E:
			body_sprite.play("Attack_E")
		elif facing == dir.NE:
			body_sprite.play("Attack_NE")
		elif facing == dir.SE:
			body_sprite.play("Attack_SE")
		elif facing == dir.SW:	
			body_sprite.play("Attack_SW")
		elif facing == dir.NW:
			body_sprite.play("Attack_NW")
			
func MoveEnemy(new_position, new_facing, attacking):
	if !attacking:
		if state != "Dead":
			if new_position == position: # Standing still
				if new_facing == dir.S:
					body_sprite.play("idle_down")
				elif new_facing == dir.N:
					body_sprite.play("idle_up")
				elif new_facing == dir.W:
					body_sprite.play("idle_left")
				elif new_facing == dir.E:
					body_sprite.play("idle_right")
				elif new_facing == dir.NE:
					body_sprite.play("idle_NE")	
				elif new_facing == dir.SE:
					body_sprite.play("idle_SE")
				elif new_facing == dir.SW:	
					body_sprite.play("idle_SW")
				elif new_facing == dir.NW:
					body_sprite.play("idle_NW")
			else:
				if new_facing == dir.S:
					body_sprite.play("walk_down")
				elif new_facing == dir.N:	
					body_sprite.play("walk_up")
				elif new_facing == dir.W:
					body_sprite.play("walk_left")
				elif new_facing == dir.E:
					body_sprite.play("walk_right")
				elif new_facing == dir.NE:
					body_sprite.play("walk_NE")
				elif new_facing == dir.SE:	
					body_sprite.play("walk_SE")
				elif new_facing == dir.SW:	
					body_sprite.play("walk_SW")
				elif new_facing == dir.NW:
					body_sprite.play("walk_NW")
	else:
		Attack()
				
	
	set_position(new_position)
	
func Health(new_health):
	if new_health != health:
		health = new_health
		HealthBarUpdate()
		if health <= 0:
			OnDeath()

func HealthBarUpdate():
	health_bar.value = health

func OnDeath():

	get_node("RigidBody2D/CollisionShape2D").set_deferred("disabled", true)
	get_node("SwingBody/CollisionShape2D").set_deferred("disabled", true)
	get_node("Body Sprite").play("Dead") #Death animation
	state = "Dead"
	health_bar.hide()
	selected.hide()
	player_ref.stop_attacking()
	player_ref.set_focused(null)
	var timer = Timer.new()
	timer.wait_time = 10
	timer.autostart = true
	timer.timeout.connect(DeleteSelf)
	self.add_child(timer)
	clickable = false
	#z_index= -1
	
func _process(delta):
	health_bar.value = health
	if player_ref.get_attack_mode():
		selected.modulate = Color(1,0,0)
		if selected.visible:
			player_ref.set_focused(self)
	else:
		selected.modulate = Color(1,1,1)

	if selected.visible:
		var addition = grow_amount * delta
		if select_growing:
			selected.scale = selected.scale + Vector2(addition, addition)
		else:
			selected.scale = selected.scale - Vector2(addition, addition)
			
		if selected.scale .x >= max_scale.x:
			selected.scale  = max_scale
			select_growing = false
		elif selected.scale .x <= default_scale.x:
			selected.scale  = default_scale
			select_growing = true
	
	if !player_ref.get_attack_mode():
		GameManager.set_attack_cursor(false)
	
	#if hovering:
		#if player_ref.get_attack_mode():
			#GameManager.set_attack_cursor(true)
		#else:
			#GameManager.set_attack_cursor(false)
	
	if player_colliding && selected.visible:
		if !player_ref.get_in_battle() && player_ref.get_attack_mode():
			player_ref.start_attacking()
			
	attack_prev_frame = player_ref.get_attacking()
	
	#apply damage #LOCAL
	#if selected.visible:
		#health -= player_ref.apply_damage()
		#player_ref.reset_damage()

	#apply damage #NETWORK
	#if selected.visible && player_ref.get_attack_mode() && player_colliding:
	
	
	

func DeleteSelf():
	queue_free()
		
func _input(event):
	if !hovering:
		if event.is_action_pressed("pickup"):
			selected.visible = false
			health_bar.visible = false
			player_ref.stop_attacking()
	
func _physics_process(_delta: float) -> void:
	pass

func _on_timer_timeout():
	set_physics_process(true)

func _on_button_pressed():
	if clickable:
		if !selected.visible:
			selected.visible = true
			health_bar.visible = true
			GameManager.set_target(self.name)

func _on_selector_button_mouse_entered():
	hovering = true
	if player_ref.get_attack_mode():
		GameManager.set_attack_cursor(true)
	else: 
		GameManager.set_attack_cursor(false)

func _on_selector_button_mouse_exited():
	hovering = false
	GameManager.set_attack_cursor(false)

func _on_swing_body_body_entered(body):
	if body == player_ref:
		player_colliding = true

func _on_swing_body_body_exited(body):
	if body == player_ref:
		player_colliding = false
		player_ref.stop_attacking()
