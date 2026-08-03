extends Node
class_name HM_Glove

@onready var ui_glove: UIGlove = %UIGlove
@onready var real_glove: RealGlove = %RealGlove

## Plant type na kasalukuyang hawak (Null kung wala)
var picked_plant_type: CharacterRegistry.PlantType = CharacterRegistry.PlantType.Null
## Pinanggalingang cell ng hawak na plant
var source_cell: PlantCell = null
## Cell na kinatatapatan ng mouse ngayon
var curr_plant_cell: PlantCell = null

func click_glove():
	real_glove.change_is_using(true)

func item_process() -> void:
	pass

## Mouse pumasok sa cell
func mouse_enter(plant_cell: PlantCell):
	curr_plant_cell = plant_cell

## Mouse lumabas ng cell
func mouse_exit(_plant_cell: PlantCell):
	curr_plant_cell = null

## Click sa cell — pumipili kung pickup o place depende kung may hawak na
func click_cell(plant_cell: PlantCell):
	if picked_plant_type == CharacterRegistry.PlantType.Null:
		_try_pick_up(plant_cell)
	else:
		_try_place_down(plant_cell)

## Kunin yung plant sa cell (Norm position lang sa ngayon)
func _try_pick_up(plant_cell: PlantCell):
	var plant: Plant000Base = plant_cell.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm]
	if not is_instance_valid(plant):
		return

	picked_plant_type = plant.plant_type
	source_cell = plant_cell
	plant.character_death_disappear()
	## Agad i-clear yung dictionary entry, huwag maghintay sa queue_free()
	plant_cell.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm] = null

	SoundManager.play_other_SFX("seedlift")
	real_glove.show_held_plant(picked_plant_type)

## Ilagay/i-fuse yung hawak na plant sa target cell
func _try_place_down(target_cell: PlantCell):
	var existing_plant: Plant000Base = target_cell.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm]

	## Parehong cell -> kanselahin, ibalik sa pinanggalingan
	if target_cell == source_cell:
		source_cell.create_plant(picked_plant_type)
		_reset()
		return

	if is_instance_valid(existing_plant):
		var fusion_type = Global.character_registry.get_fusion_result(existing_plant.plant_type, picked_plant_type)
		if fusion_type != CharacterRegistry.PlantType.Null:
			## May valid fusion -> tanggalin yung existing, gawa ng bagong fused plant
			existing_plant.character_death_disappear()
			target_cell.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm] = null
			target_cell.create_plant(fusion_type)
			SoundManager.play_other_SFX("plant2")
		else:
			## Walang fusion, may laman na yung target -> ibalik sa pinanggalingan
			source_cell.create_plant(picked_plant_type)
	else:
		## Walang laman ang target -> ililipat lang doon
		target_cell.create_plant(picked_plant_type)

	_reset()

## I-clear yung state ng hawak na plant
func _reset():
	picked_plant_type = CharacterRegistry.PlantType.Null
	source_cell = null
	real_glove.clear_held_plant()

## Palabas sa kasalukuyang estado (right-click / kanselahin habang may hawak)
func exit_status():
	if picked_plant_type != CharacterRegistry.PlantType.Null and is_instance_valid(source_cell):
		## Ibalik yung hawak na plant sa pinanggalingan
		source_cell.create_plant(picked_plant_type)
	_reset()
	real_glove.change_is_using(false)
	ui_glove.ui_glove_appear()
