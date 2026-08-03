extends Sprite2D
class_name RealGlove

var is_using := false
@onready var held_plant_container: Node2D = $HeldPlantContainer

func _process(_delta: float) -> void:
	if is_using:
		global_position = get_global_mouse_position()

func change_is_using(value: bool):
	is_using = value
	visible = value
	if not value:
		clear_held_plant()

## Ipakita yung sprite ng hawak na plant, susunod sa glove
func show_held_plant(plant_type: CharacterRegistry.PlantType):
	print("=== show_held_plant tinawag, plant_type: ", plant_type)
	clear_held_plant()
	if plant_type == CharacterRegistry.PlantType.Null:
		print("=== plant_type ay Null, lalabas na")
		return
	var card: Card = AllCards.all_plant_card_prefabs.get(plant_type)
	if card == null:
		print("=== WALANG NAHANAP na card para dito!")
		return
	print("=== nahanap yung card: ", card.name)
	var preview := card.character_static.duplicate()
	print("=== na-duplicate, bilang ng anak: ", preview.get_children().size())
	preview.scale = Vector2.ONE * 2
	preview.position = Vector2(0, -40)
	preview.z_index = -1
	preview.z_as_relative = true
	held_plant_container.add_child(preview)
	print("=== na-add na sa container, bilang ng anak ngayon: ", held_plant_container.get_children().size())
	print("=== held_plant_container global_position: ", held_plant_container.global_position)
	print("=== held_plant_container visible: ", held_plant_container.visible)

## Alisin yung preview ng hawak na plant
func clear_held_plant():
	for child in held_plant_container.get_children():
		child.queue_free()
