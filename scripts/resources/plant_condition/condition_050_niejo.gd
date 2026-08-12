extends ResourcePlantCondition
class_name ResourcePlantConditionNiejo


var RECIPES = [

	# Wall Wall Wall
	{
		"ordered": false,
		"plants":[
			CharacterRegistry.PlantType.P002SunFlower,
			CharacterRegistry.PlantType.P002SunFlower,
			CharacterRegistry.PlantType.P002SunFlower,
		],
		"reward":CharacterRegistry.PlantType.P02001Solara, 
	},

	# Wall Tall Wall
	{
		"ordered": true,
		"plants":[
			CharacterRegistry.PlantType.P004WallNut,
			CharacterRegistry.PlantType.P024TallNut,
			CharacterRegistry.PlantType.P004WallNut,
		],
		"reward":CharacterRegistry.PlantType.P02000FortnessNut,
	},

	# Sun Wall Tall
	{
		"ordered": true,
		"plants":[
			CharacterRegistry.PlantType.P008PeaShooterDouble,
			CharacterRegistry.PlantType.P019ThreePeater,
			CharacterRegistry.PlantType.P008PeaShooterDouble,
		],
		"reward":CharacterRegistry.PlantType.P02002WarPea,
	},

]


func _match_recipe(mid_cell: PlantCell) -> Dictionary:

	var row := mid_cell.row_col.x
	var col := mid_cell.row_col.y
	var all_cells = Global.main_game.plant_cell_manager.all_plant_cells

	if col <= 0 or col >= all_cells[row].size() - 1:
		return {}

	var left_cell: PlantCell = all_cells[row][col - 1]
	var right_cell: PlantCell = all_cells[row][col + 1]

	var left := _get_plant_type(left_cell)
	var mid := _get_plant_type(mid_cell)
	var right := _get_plant_type(right_cell)

	if left == CharacterRegistry.PlantType.Null:
		return {}

	if mid == CharacterRegistry.PlantType.Null:
		return {}

	if right == CharacterRegistry.PlantType.Null:
		return {}

	var found = [left, mid, right]
	found.sort()

	for recipe in RECIPES:

		if recipe["ordered"]:

			if left == recipe["plants"][0] \
			and mid == recipe["plants"][1] \
			and right == recipe["plants"][2]:

				return {
					"cells":[left_cell, mid_cell, right_cell],
					"reward":recipe["reward"]
				}

		else:

			var r = recipe["plants"].duplicate()
			r.sort()

			if found == r:

				return {
					"cells":[left_cell, mid_cell, right_cell],
					"reward":recipe["reward"]
				}

	return {}


func _get_plant_type(cell: PlantCell) -> CharacterRegistry.PlantType:

	for place in [
		CharacterRegistry.PlacePlantInCell.Norm,
		CharacterRegistry.PlacePlantInCell.Shell,
	]:

		var p: Plant000Base = cell.plant_in_cell[place]

		if is_instance_valid(p):
			return p.plant_type

	return CharacterRegistry.PlantType.Null
