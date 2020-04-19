extends Node2D

export (PackedScene) var BULLET
export (PackedScene) var DNA
export (PackedScene) var TURRET
export (PackedScene) var VIRUS

var viruses : Array = []
var spawn_point_idxs : Array = []
var spawn_count : int = 0
var round_number : int = 0
var game_active : bool = true

var protein : int = 0

func color_lerp(c1 : Color, c2 : Color, t: float):
	return Color(
		lerp(c1.r, c2.r, t),
		lerp(c1.g, c2.g, t),
		lerp(c1.b, c2.b, t),
		lerp(c1.a, c2.a, t)
	)


func _ready():
	for i in range(10):
		print(i/10, ": ", color_lerp(Color(0.8, 0.2, 0.2, 1.0), Color(0.2, 0.2, 0.8, 1.0), i/10))

	randomize()
	for i in range($VirusLandingZones.get_child_count()):
		spawn_point_idxs.append(i)
	start_round()
	
func round_virus_count(r):
	match r:
		1: return 1
		2: return 2
		3: return 3
		4: return 5
		5: return 8
		6: return 10
		7: return 13
		_: return $VirusLandingZones.get_child_count()
	
func round_spawn_count(r):
	return r * 10
	
func round_spawn_interval(r):
	match r:
		1: return 0.5
		2: return 0.4
		3: return 0.35
		4: return 0.32
		5: return 0.31
		6: return 0.3
		_: return 0.25
	
func round_dna_health(r):
	match r:
		1: return 1
		2: return 2
		3: return 2
		4: return 3
		5: return 3
		6: return 3
		7: return 4
		8: return 4
		9: return 4
		10: return 4
		11: return 4
		_: return 5
	
func start_round():
	if !game_active:
		return
		
	round_number += 1
	$HUD/RoundLabel.text = "Round: " + str(round_number)
	
	# Round settings
	spawn_count = round_spawn_count(round_number)
	$SpawnTimer.wait_time = round_spawn_interval(round_number)
	
	# Set preperation phase
	$PreperationTimer.start()
	$SpawnTimer.stop()
	
	# Remove viruses from previous round
	for i in range(viruses.size()):
		viruses[i].launch()
	viruses.clear()
	
	# Choose a random selection of spawn points
	var spawn_points : Array = []
	spawn_point_idxs.shuffle()
	for i in range(round_virus_count(round_number)):
		#spawn_points.append(spawn_point_idxs[i])
		spawn_points.append(i)
	
	# Spawn new viruses
	for i in spawn_points:
		var position : Node2D = $VirusLandingZones.get_child(i)
		var virus = VIRUS.instance()
		virus.transform = position.transform
		add_child(virus)
		viruses.append(virus)
		virus.land()

func _process(_delta):
	if !game_active:
		return
	
	if !$PreperationTimer.is_stopped():
		$HUD/StatusLabel.text = "Preperation: %.1f" % $PreperationTimer.time_left
	elif spawn_count == 0 && $DNAs.get_child_count() == 0:
		start_round()
	else:
		var enemies = $DNAs.get_child_count() + spawn_count
		$HUD/StatusLabel.text = "Enemys remaining: " + str(enemies)
	
	# Disable player input when in menu	
	$Player.input_enabled = !$HUD.in_menu()
	
	# Cheats
	if Input.is_action_just_pressed("cheat_give_protein"):
		update_protein(protein + 100)

func _on_Player_shoot_bullet(pos, rot, velocity, pierce, damage):
	var bullet : RigidBody2D = BULLET.instance()
	bullet.pierce = pierce
	bullet.damage = damage
	bullet.position = pos
	bullet.rotation = rot
	bullet.linear_velocity = velocity + Vector2(cos(rot), sin(rot)) * 300
	add_child(bullet)

func update_protein(new_protein):
	protein = new_protein
	$HUD.set_protein_score(new_protein)

func _on_SpawnTimer_timeout():
	for v in viruses:
		if spawn_count <= 0:
			break
		var spawn_point : Vector2 = v.get_node("Spawn").global_position
		var dna = DNA.instance()
		dna.position = spawn_point
		dna.set_target($Nucleaus.global_position)
		dna.set_max_health(round_dna_health(round_number))
		$DNAs.add_child(dna)
		spawn_count -= 1

func _on_Player_protein_pickup():
	update_protein(protein + 1)

func add_nucleaus_shop_buttons():
	$HUD.add_shop_button("Turret (40pp)", "turret", true)
	$HUD.add_shop_button("Left Gun (40pp)", "left_gun", !$Player.guns_unlocked[0])
	$HUD.add_shop_button("Right Gun (40pp)", "right_gun", !$Player.guns_unlocked[2])
	$HUD.add_shop_button("Pierce (100pp)", "pierce", !$Player.pierce_unlocked)
	$HUD.add_shop_button("Damage (200pp)", "damage", $Player.bullet_damage == 1)
	$HUD.add_shop_button("Damage2 (400pp)", "damage2", $Player.bullet_damage == 2)
	
func _on_Nucleaus_open_nucleaus_shop():
	$HUD.open_store()
	$HUD.set_shop_label("Nucleaus")
	add_nucleaus_shop_buttons()
	
func _on_HUD_store_purchase(key):
	print("trying to purchase: ", key)
	match key:
		"turret":
			if protein >= 40:
				if $Player.add_to_inventory("turret"):
					update_protein(protein - 40)
		"left_gun":
			if protein >= 40 && !$Player.guns_unlocked[0]:
				update_protein(protein - 40)
				$Player.guns_unlocked[0] = true
		"right_gun":
			if protein >= 40 && !$Player.guns_unlocked[2]:
				update_protein(protein - 40)
				$Player.guns_unlocked[2] = true
		"pierce":
			if protein >= 100 && !$Player.pierce_unlocked:
				update_protein(protein - 100)
				$Player.pierce_unlocked = true
		"damage":
			if protein >= 200 && $Player.bullet_damage == 1:
				update_protein(protein - 200)
				$Player.bullet_damage = 2
		"damage2":
			if protein >= 400 && $Player.bullet_damage == 2:
				update_protein(protein - 400)
				$Player.bullet_damage = 3
	$HUD.clear_shop_buttons()
	add_nucleaus_shop_buttons()

func _on_Player_place_turret(pos, rot):
	var turret = TURRET.instance()
	turret.position = pos
	turret.rotation = rot
	turret.connect("shoot_bullet", self, "_on_Player_shoot_bullet")
	add_child(turret)

func _on_PreperationTimer_timeout():
	for child in $Protein.get_children():
		child.queue_free()
	$SpawnTimer.start() # start round

func _on_RestartButton_pressed():
	get_tree().reload_current_scene()

func _on_Nucleaus_nucleaus_dead():
	print("Game over :(")
	game_active = false
	$PreperationTimer.stop()
	$SpawnTimer.stop()
	$Player.input_enabled = false
	$HUD/GameOverBox.visible = true

func _on_Player_open_mitocondria_shop():
	$HUD.open_store()
	$HUD.set_shop_label("Mitocondria")
	add_mitocondria_shop_buttons()

func add_mitocondria_shop_buttons():
	$HUD.add_shop_button("Left Gun (40pp)", "left_gun", !$Player.guns_unlocked[0])
	$HUD.add_shop_button("Right Gun (40pp)", "right_gun", !$Player.guns_unlocked[2])
	$HUD.add_shop_button("Pierce (100pp)", "pierce", !$Player.pierce_unlocked)
	$HUD.add_shop_button("Damage (200pp)", "damage", $Player.bullet_damage == 1)
	$HUD.add_shop_button("Damage2 (400pp)", "damage2", $Player.bullet_damage == 2)
