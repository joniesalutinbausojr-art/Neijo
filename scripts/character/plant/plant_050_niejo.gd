extends Plant000Base
class_name Plant050Niejo

@export var process_time: float = 2.5
@export var reward_plant_type: CharacterRegistry.PlantType = CharacterRegistry.PlantType.P003CherryBomb

var _left_cell: PlantCell
var _mid_cell: PlantCell
var _right_cell: PlantCell
var _is_processing := false

func ready_norm():
	super()
	z_index = 5
	position.y += 20
	_start_niejo_process()

func _start_niejo_process() -> void:
	if _is_processing:
		return
	_is_processing = true

	var cond: ResourcePlantConditionNiejo = Global.character_registry.get_plant_info(
		plant_type, CharacterRegistry.PlantInfoAttribute.PlantConditionResource
	) as ResourcePlantConditionNiejo

	var match_cells: Array = cond._match_recipe(plant_cell)
	if match_cells.is_empty():
		# Walang valid recipe — tanggalin lang ang Niejo (o huwag payagan magtanim)
		character_death_disappear()
		return

	_left_cell = match_cells[0]
	_mid_cell = match_cells[1]
	_right_cell = match_cells[2]

	# Optional: animation / glow dito
	await get_tree().create_timer(process_time).timeout

	if not is_instance_valid(self):
		return

	_consume_and_spawn_card()

func _consume_and_spawn_card() -> void:
	_kill_plants_in_cell(_left_cell)
	_kill_plants_in_cell(_mid_cell)
	_kill_plants_in_cell(_right_cell)

	# Reward card sa player
	var spawn_pos := global_position
	Global.main_game.card_manager.create_temp_card({
		CardManager.E_TempCardParaAttr.PlantType: reward_plant_type,
		CardManager.E_TempCardParaAttr.GlobalPos: spawn_pos,
		# CardManager.E_TempCardParaAttr.ExistTime: 15.0,  # optional timeout
	})

	# Niejo mismo mawawala
	character_death_disappear()

func _kill_plants_in_cell(cell: PlantCell) -> void:
	if not is_instance_valid(cell):
		return
	for place in [
		CharacterRegistry.PlacePlantInCell.Norm,
		CharacterRegistry.PlacePlantInCell.Shell,
		CharacterRegistry.PlacePlantInCell.Float,
		CharacterRegistry.PlacePlantInCell.Down,
	]:
		var p: Plant000Base = cell.plant_in_cell[place]
		if is_instance_valid(p):
			p.be_shovel_kill()  # o character_death_disappear()
