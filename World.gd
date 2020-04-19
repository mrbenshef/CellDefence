extends Node2D

export (PackedScene) var BULLET
export (PackedScene) var DNA
export (PackedScene) var TURRET
export (PackedScene) var VIRUS

var viruses : Array = []
var spawn_point_idxs : Array = []
var spawn_count : int = 0
var round_number : int = 0

var protein : int = 0

func _ready():
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
	
func start_round():
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
		spawn_points.append(spawn_point_idxs[i])
	
	# Spawn new viruses
	for i in spawn_points:
		var position : Node2D = $VirusLandingZones.get_child(i)
		var virus = VIRUS.instance()
		virus.transform = position.transform
		add_child(virus)
		viruses.append(virus)
		virus.land()
	
func _process(_delta):
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

func _on_Player_shoot_bullet(pos, rot):
	var bullet : RigidBody2D = BULLET.instance()
	bullet.position = pos
	bullet.rotation = rot
	bullet.linear_velocity = Vector2(cos(rot), sin(rot)) * 300
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
		$DNAs.add_child(dna)
		spawn_count -= 1
		

func _on_Player_protein_pickup():
	update_protein(protein + 1)

func _on_Nucleaus_open_nucleaus_shop():
	$HUD.open_nucleaus_store()

func _on_HUD_nucleaus_store_heal():
	if protein >= 40:
		if $Player.add_to_inventory("turret"):
			update_protein(protein - 40)

func _on_Player_place_turret(pos, rot):
	var turret = TURRET.instance()
	turret.position = pos
	turret.rotation = rot
	turret.connect("shoot_bullet", self, "_on_Player_shoot_bullet")
	add_child(turret)

func _on_PreperationTimer_timeout():
	$SpawnTimer.start() # start round
