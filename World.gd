extends Node2D

export (PackedScene) var BULLET
export (PackedScene) var DNA
export (PackedScene) var TURRET
export (PackedScene) var VIRUS

onready var spawnPoint : Vector2 = $SpawnPoint.position
var viruses : Array = []
var spawn_count : int = 1
var round_number : int = 0

var protein : int = 0

func _ready():
	start_round()
	
func start_round():
	round_number += 1
	$HUD/RoundLabel.text = "Round: " + str(round_number)
	
	# Set preperation phase
	$PreperationTimer.start()
	$SpawnTimer.stop()
	
	# Remove viruses from previous round
	for i in range(viruses.size()):
		viruses[i].launch()
	viruses.clear()
	
	# Spawn new viruses
	for position in $VirusLandingZones.get_children():
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
		$HUD/StatusLabel.text = "Enemys remaining: " + str($DNAs.get_child_count())
	
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
