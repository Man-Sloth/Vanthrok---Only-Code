extends CharacterBody2D

const speed = 10000

@export var player: Node2D = null
@onready var nav_agent = $NavigationAgent2D
@onready var selected = $Selected
@onready var health_bar = $HealthBar
@onready var player_ref = $"../../Player"

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

func MoveEnemy(new_position):
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
	if selected.visible:
		GameServer.NPCHit(get_name().to_int(), player_ref.apply_damage())
		player_ref.reset_damage()
	
	

func DeleteSelf():
	queue_free()
		
func _input(event):
	if !hovering:
		if event.is_action_pressed("pickup"):
			selected.visible = false
			health_bar.visible = false
	

func _physics_process(_delta: float) -> void:
	var dir = to_local(nav_agent.get_next_path_position()).normalized()
	var new_velocity = dir * speed * _delta
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
		
	move_and_slide()
	
func makepath() -> void:
	nav_agent.target_position = player.global_position

func _on_timer_timeout():
	set_physics_process(true)
	#makepath() #Makes bear follow player locally

func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	velocity = safe_velocity

func _on_button_pressed():
	if clickable:
		if !selected.visible:
			selected.visible = true
			health_bar.visible = true

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
			if(selected.visible && player_ref.get_attack_mode()):
				player_ref.start_attacking()

func _on_swing_body_body_exited(body):
		if body == player_ref:
			player_colliding = false
			if selected.visible:
				player_ref.stop_attacking()
