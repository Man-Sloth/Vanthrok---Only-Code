extends Node2D

const PLAYER_SPAWN = preload("res://Scenes/PlayerTemplate.tscn")
const ENEMY_SPAWN = preload("res://Scenes/Enemy.tscn")
var last_world_state = 0
var world_state_buffer = []
var interpolation_offset = 100

func SpawnNewPlayer(player_id, spawn_position):
	if multiplayer.get_unique_id() == player_id:
		pass
	else:
		if !get_node("OtherPlayers").has_node(str(player_id)):
			var new_player = PLAYER_SPAWN.instantiate()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			get_node("OtherPlayers").add_child(new_player)
		
func DespawnPlayer(player_id):
	# TO-DO 5-10 second timer for logging off player
	await get_tree().create_timer(0.2).timeout # For crashed players
	get_node("OtherPlayers/" + str(player_id)).queue_free()

func UpdateWorldState_old(world_state):
	# Buffer
	# Interpolation
	# Extrapolation
	# Rubber Banding
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state.erase("T")
		world_state.erase(multiplayer.get_unique_id())
		for player in world_state.keys():
			if get_node("OtherPlayers").has_node(str(player)):
				get_node(("OtherPlayers/") + str(player)).MovePlayer(world_state[player]["P"])
			else:
				print("spawning player")
				SpawnNewPlayer(player, world_state[player]["P"])
						
func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)
		
func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	#var render_time = (Time.get_unix_time_from_system() * 1000) - interpolation_offset
	if world_state_buffer.size() > 1:
		#var worldstate = world_state_buffer[1]["T"]
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2]["T"]:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2: #We have future states
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) ==  "Enemies":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if !world_state_buffer[1].has(player):
					continue
				if get_node("OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					var facing = world_state_buffer[2][player]["A"]
					var mode = world_state_buffer[2][player]["M"]
					get_node("OtherPlayers/" + str(player)).MovePlayer(new_position, facing, mode)
				else:
					print("spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
			for enemy in world_state_buffer[2]["Enemies"].keys():
				if not world_state_buffer[1]["Enemies"].has(enemy):
					continue
				if get_node("Enemies").has_node(str(enemy)):
					var new_position = lerp(world_state_buffer[1]["Enemies"][enemy]["EnemyLocation"], world_state_buffer[2]["Enemies"][enemy]["EnemyLocation"], interpolation_factor)
					get_node("Enemies/" + str(enemy)).MoveEnemy(new_position)
					get_node("Enemies/" + str(enemy)).Health(world_state_buffer[1]["Enemies"][enemy]["EnemyHealth"])
				else:
					SpawnNewEnemy(enemy, world_state_buffer[2]["Enemies"][enemy])
		elif render_time > world_state_buffer[1]["T"]: #We have no future world state
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == "Enemies":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if !world_state_buffer[0].has(player):
					continue
				if get_node("OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					if world_state_buffer.size() >= 1:
						var facing = world_state_buffer[2][player]["A"]
						var mode = world_state_buffer[2][player]["M"]
						get_node("OtherPlayers/" + str(player)).MovePlayer(new_position, facing, mode)
					
func SpawnNewEnemy(enemy_id, enemy_dict):
	var new_enemy = ENEMY_SPAWN.instantiate()
	new_enemy.position = enemy_dict["EnemyLocation"]
	new_enemy.max_health = enemy_dict["EnemyMaxHealth"]
	new_enemy.health = enemy_dict["EnemyHealth"]
	new_enemy.type = enemy_dict["EnemyType"]
	new_enemy.state = enemy_dict["EnemyState"]
	new_enemy.name = str(enemy_id)
	get_node("Enemies/").add_child(new_enemy, true)

