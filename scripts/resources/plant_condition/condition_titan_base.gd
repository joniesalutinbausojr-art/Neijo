extends ResourcePlantCondition
class_name ResourcePlantConditionTitan

## Reusable 2-cell Titan planting logic
## Priority: right (towards zombies) → left (towards house)

func _judge_special_plants_condition(plant_cell: PlantCell) -> bool:
	if not (plant_cell.can_common_plant and plant_condition & plant_cell.curr_condition):
		return false
	return get_titan_neighbor_cell(plant_cell) != null


func get_titan_neighbor_cell(plant_cell: PlantCell) -> PlantCell:
	var manager: PlantCellManager = Global.main_game.plant_cell_manager
	var max_col: int = manager.row_col.y

	# Right (towards zombies)
	if plant_cell.row_col.y + 1 < max_col:
		var right_cell: PlantCell = manager.all_plant_cells[plant_cell.row_col.x][plant_cell.row_col.y + 1]
		if _cell_free_for_titan(right_cell):
			return right_cell

	# Left (towards house)
	if plant_cell.row_col.y - 1 >= 0:
		var left_cell: PlantCell = manager.all_plant_cells[plant_cell.row_col.x][plant_cell.row_col.y - 1]
		if _cell_free_for_titan(left_cell):
			return left_cell

	return null


func _cell_free_for_titan(cell: PlantCell) -> bool:
	return cell.can_common_plant \
		and (plant_condition & cell.curr_condition) != 0 \
		and not is_instance_valid(cell.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm])
