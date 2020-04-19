extends CanvasLayer

export (PackedScene) var ITEM_BUTTON
export (Texture) var TurretTexture

onready var BlankTexture : Texture = Texture.new()

export (Color) var DefaultColor
export (Color) var SelectedColor

signal store_purchase

func _ready():
	$Shop.visible = false
	$TooltipLabel.visible = false
	$GameOverBox.visible = false

func _process(delta):
	$TooltipLabel.rect_position = get_viewport().get_mouse_position() + Vector2(10, 10)

	if Input.is_action_just_pressed("ui_cancel"):
		print("escape, closing store")
		close_store()

func set_protein_score(score):
	$ProteinScore.text = "Protein Points: " + str(score)

func set_tooltip(text, visible):
	$TooltipLabel.text = text
	$TooltipLabel.visible = visible

func _on_Player_inventory_update(inventory):
	for i in range(inventory.size()):
		var sprite : Sprite = find_node("InventorySprite" + str(i + 1))
		if sprite == null:
			continue
		match inventory[i]:
			"turret":
				sprite.texture = TurretTexture
			_:
				sprite.texture = BlankTexture
	
func _on_Player_select_update(idx):
	print("player select: ", idx)
	for i in range(9):
		var rect : ColorRect = find_node("InventorySprite" + str(i + 1)).get_parent()
		if i == idx:
			rect.color = SelectedColor
		else:
			rect.color = DefaultColor
	
func open_store():
	$Shop.visible = true

func close_store():
	$Shop.visible = false
	for button in $Shop/ScrollContainer/GridContainer.get_children():
		button.queue_free()

func in_menu():
	return $Shop.visible

func set_shop_label(text):
	$Shop/ShopLabel.text = text

func add_shop_button(text, key, enabled):
	var button : Button = ITEM_BUTTON.instance()
	button.text = text
	button.disabled = !enabled
	button.connect("pressed", self, "_on_item_button_pressed", [key])
	$Shop/ScrollContainer/GridContainer.add_child(button)

func clear_shop_buttons():
	for button in $Shop/ScrollContainer/GridContainer.get_children():
		button.queue_free()
		
func _on_item_button_pressed(key):
	emit_signal("store_purchase", key)

func _on_CloseButton_pressed():
	close_store()


