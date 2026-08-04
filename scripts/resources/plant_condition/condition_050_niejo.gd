extends ResourcePlantCondition
class_name ResourcePlantConditionNiejo

## Recipe: left / middle / right (pahalang, same row)
const LEFT_TYPE := CharacterRegistry.PlantType.P004WallNut
const MID_TYPE := CharacterRegistry.PlantType.P024TallNut
const RIGHT_TYPE := CharacterRegistry.PlantType.P031Pumpkin

func _judge_special_plants_condition(plant_cell: PlantCell) -> bool:
	return _match_recipe(plant_cell) != null

## Ibalik ang [left_cell, mid_cell, right_cell] kung valid, else null
func _match_recipe(mid_cell: PlantCell) -> Array:
	var row := mid_cell.row_col.x
	var col := mid_cell.row_col.y
	var all_cells = Global.main_game.plant_cell_manager.all_plant_cells

	# Kailangan may kaliwa at kanan
	if col <= 0 or col >= all_cells[row].size() - 1:
		return []

	var left_cell: PlantCell = all_cells[row][col - 1]
	var right_cell: PlantCell = all_cells[row][col + 1]

	if not _has_plant_type(left_cell, LEFT_TYPE):
		return []
	if not _has_plant_type(mid_cell, MID_TYPE):
		return []
	if not _has_plant_type(right_cell, RIGHT_TYPE):
		return []

	return [left_cell, mid_cell, right_cell]

func _has_plant_type(cell: PlantCell, t: CharacterRegistry.PlantType) -> bool:
	# Tingnan Norm (at Shell kung Pumpkin)
	for place in [
		CharacterRegistry.PlacePlantInCell.Norm,
		CharacterRegistry.PlacePlantInCell.Shell,
	]:
		var p: Plant000Base = cell.plant_in_cell[place]
		if is_instance_valid(p) and p.plant_type == t:
			return true
	return false
