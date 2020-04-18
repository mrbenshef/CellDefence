extends Node2D

export (PackedScene) var BULLET
export (PackedScene) var DNA
export (PackedScene) var TURRET
onready var spawnPoint : Vector2 = $SpawnPoint.position

var protein : int = 0

func _ready():
	pass
	
func _process(_delta):
	$Player.input_enabled = !$HUD.in_menu()
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
	print("Spawning DNA!")
	var dna = DNA.instance()
	dna.position = spawnPoint
	#dna.rotation = rand_range(0, 2 * PI)
	dna.set_target($Nucleaus.global_position)
	add_child(dna)

func _on_Player_protein_pickup():
	update_protein(protein + 1)

func _on_Nucleaus_open_nucleaus_shop():
	$HUD.open_nucleaus_store()

func _on_HUD_nucleaus_store_heal():
	if protein >= 40:
		update_protein(protein - 40)
		
func _on_Player_place_turret(pos, rot):
	var turret = TURRET.instance()
	turret.position = pos
	turret.rotation = rot
	add_child(turret)
	
