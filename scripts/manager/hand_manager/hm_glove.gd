extends Node
class_name HM_Glove

@onready var ui_glove: UIGlove = %UIGlove
@onready var real_glove: RealGlove = %RealGlove

var picked_place: CharacterRegistry.PlacePlantInCell = CharacterRegistry.PlacePlantInCell.Norm

## Plant type na kasalukuyang hawak (Null kung wala)
var picked_plant_type: CharacterRegistry.PlantType = CharacterRegistry.PlantType.Null
## HP ng hawak na plant noong kinuha (ipapanumbalik pag inilagay ulit)
var picked_plant_hp: int = -1
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

	var plant: Plant000Base = plant_cell.return_plant_be_shovel_look()

	if not is_instance_valid(plant):
		return

	var place := CharacterRegistry.PlacePlantInCell.Norm

	for p in plant_cell.plant_in_cell.keys():
		if plant_cell.plant_in_cell[p] == plant:
			place = p
			break

	picked_place = place
	picked_plant_type = plant.plant_type
	picked_plant_hp = plant.hp_component.curr_hp
	source_cell = plant_cell

	plant.character_death_disappear()
	plant_cell.plant_in_cell[place] = null

	SoundManager.play_other_SFX("seedlift")
	real_glove.show_held_plant(picked_plant_type)

	SoundManager.play_other_SFX("seedlift")
	real_glove.show_held_plant(picked_plant_type)

## Ilagay/i-fuse yung hawak na plant sa target cell
func _try_place_down(target_cell: PlantCell):

	var existing_plant: Plant000Base = target_cell.plant_in_cell[picked_place]

	## Parehong cell -> ibalik
	if target_cell == source_cell:
		var restored_plant: Plant000Base = source_cell.create_plant(picked_plant_type)
		_restore_hp(restored_plant)
		_reset()
		return

	if is_instance_valid(existing_plant):

		var fusion_type = Global.character_registry.get_fusion_result(
			existing_plant.plant_type,
			picked_plant_type
		)

		if fusion_type != CharacterRegistry.PlantType.Null:

			existing_plant.character_death_disappear()
			target_cell.plant_in_cell[picked_place] = null

			target_cell.create_plant(fusion_type)
			SoundManager.play_other_SFX("plant2")

		else:

			var restored_plant: Plant000Base = source_cell.create_plant(picked_plant_type)
			_restore_hp(restored_plant)
			_reset()
			return

	else:

		## Walang existing plant -> siguraduhing puwede talaga dito bago ilagay
		## (hal. ice road na iniwan ng driver zombie, tubig, bubog, sementeryo, atbp.)
		var target_condition: ResourcePlantCondition = Global.character_registry.get_plant_info(
			picked_plant_type, CharacterRegistry.PlantInfoAttribute.PlantConditionResource
		)

		if not target_condition.judge_is_can_plant(target_cell, picked_plant_type):
			## Hindi puwede dito -> ibalik na lang sa pinanggalingan
			SoundManager.play_other_SFX("buzzer")
			var restored_plant: Plant000Base = source_cell.create_plant(picked_plant_type)
			_restore_hp(restored_plant)
			_reset()
			return

		var restored_plant: Plant000Base = target_cell.create_plant(picked_plant_type)
		_restore_hp(restored_plant)

	_reset()

## Ipanumbalik ang HP ng nilipat na plant (kung mayroon), pagkatapos i-clear ang naka-imbak na value
func _restore_hp(plant: Plant000Base):
	if is_instance_valid(plant) and picked_plant_hp > 0:
		plant.hp_component.curr_hp = picked_plant_hp
	picked_plant_hp = -1

## I-clear yung state ng hawak na plant
func _reset():
	picked_plant_type = CharacterRegistry.PlantType.Null
	picked_plant_hp = -1
	source_cell = null
	real_glove.clear_held_plant()

## Palabas sa kasalukuyang estado (right-click / kanselahin habang may hawak)
func exit_status():
	if picked_plant_type != CharacterRegistry.PlantType.Null and is_instance_valid(source_cell):
		## Ibalik yung hawak na plant sa pinanggalingan
		var restored_plant: Plant000Base = source_cell.create_plant(picked_plant_type)
		_restore_hp(restored_plant)
	_reset()
	real_glove.change_is_using(false)
	ui_glove.ui_glove_appear()
