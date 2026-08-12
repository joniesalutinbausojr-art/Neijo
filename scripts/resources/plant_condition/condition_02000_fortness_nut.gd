extends ResourcePlantConditionTitan
class_name ResourcePlantConditionFortnessNut

<<<<<<< Updated upstream
## 堡垒坚果(Titan/巨型植物)种植判定
## 需要锚点格子 + 一个相邻格子(同一行内)都空闲才能种植
## 优先占用右侧(朝僵尸方向)格子，若不可用则占用左侧(朝房子方向)格子
func _judge_special_plants_condition(plant_cell: PlantCell) -> bool:
	## 锚点格子地形/特殊状态判断(普通植物本该有的判断，特殊植物需要手动判断)
	if not (plant_cell.can_common_plant and plant_condition & plant_cell.curr_condition):
		return false
	return get_titan_neighbor_cell(plant_cell) != null


## 获取巨型植物要额外占用的相邻格子
## 优先朝僵尸方向(row_col.y + 1，右侧)
## 其次朝房子方向(row_col.y - 1，左侧)
## 都不满足条件时返回 null（不可种植）
func get_titan_neighbor_cell(plant_cell: PlantCell) -> PlantCell:
	var plant_cell_manager: PlantCellManager = Global.main_game.plant_cell_manager
	var max_col: int = plant_cell_manager.row_col.y

	## 朝僵尸方向(右侧)
	if plant_cell.row_col.y + 1 < max_col:
		var right_cell: PlantCell = plant_cell_manager.all_plant_cells[plant_cell.row_col.x][plant_cell.row_col.y + 1]
		if _cell_free_for_titan(right_cell):
			return right_cell

	## 朝房子方向(左侧)
	if plant_cell.row_col.y - 1 >= 0:
		var left_cell: PlantCell = plant_cell_manager.all_plant_cells[plant_cell.row_col.x][plant_cell.row_col.y - 1]
		if _cell_free_for_titan(left_cell):
			return left_cell

	return null


## 判断某格子是否可以被巨型植物占用(地形符合 + 无特殊状态阻挡 + Norm位置没有植物)
func _cell_free_for_titan(cell: PlantCell) -> bool:
	return cell.can_common_plant \
		and (plant_condition & cell.curr_condition) != 0 \
		and not is_instance_valid(cell.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm])
=======
# empty for now
# ilagay dito ang special planting rules kapag kailangan
>>>>>>> Stashed changes
