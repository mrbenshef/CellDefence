extends CanvasLayer

signal nucleaus_store_heal

func _ready():
	$NucleausHUD.visible = false

func set_protein_score(score):
	$ProteinScore.text = "Protein Points: " + str(score)

func open_nucleaus_store():
	$NucleausHUD.visible = true

func in_menu():
	return $NucleausHUD.visible
