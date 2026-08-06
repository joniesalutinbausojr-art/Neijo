extends Plant000Base
class_name Plant050Niejo

@export var process_time: float = 2.5
@export var fail_wait_time: float = 10.0

var reward_plant_type: CharacterRegistry.PlantType

var _left_cell: PlantCell
var _mid_cell: PlantCell
var _right_cell: PlantCell
var _is_processing := false

func ready_norm():
	super()
	z_index = 5
	_start_niejo_process()

func _start_niejo_process() -> void:

	if _is_processing:
		return

	_is_processing = true

	var cond: ResourcePlantConditionNiejo = Global.character_registry.get_plant_info(
		plant_type,
		CharacterRegistry.PlantInfoAttribute.PlantConditionResource
	) as ResourcePlantConditionNiejo

	var result = cond._match_recipe(plant_cell)

	# ===== INVALID RECIPE =====
	if result.is_empty():

		# Siguraduhin na naka-idle habang naghihintay
		$AnimationTree.active = true
		# backup kung hindi gumana ang tree:
		if $AnimationPlayer.has_animation("Global/Niejo_idle"):
			$AnimationPlayer.play("Global/Niejo_idle")
		elif $AnimationPlayer.has_animation("Niejo_idle"):
			$AnimationPlayer.play("Niejo_idle")

		await get_tree().create_timer(fail_wait_time).timeout

		if !is_instance_valid(self):
			return

		_turn_into_card()
		return

	# ===== VALID RECIPE =====
	_left_cell = result["cells"][0]
	_mid_cell = result["cells"][1]
	_right_cell = result["cells"][2]

	reward_plant_type = result["reward"]

	# I-off ang tree para hindi ma-override ang process
	$AnimationTree.active = false

	if $AnimationPlayer.has_animation("Global/Niejo_process"):
		$AnimationPlayer.play("Global/Niejo_process")
	elif $AnimationPlayer.has_animation("Niejo_process"):
		$AnimationPlayer.play("Niejo_process")

	await get_tree().create_timer(process_time).timeout

	if !is_instance_valid(self):
		return

	_consume_and_spawn_reward()


func _consume_and_spawn_reward():
	# === Effect sa dulo (parang cherry bomb style) ===
	_play_niejo_finish_effect()

	_kill_plants_in_cell(_left_cell)
	_kill_plants_in_cell(_mid_cell)
	_kill_plants_in_cell(_right_cell)

	Global.main_game.card_manager.create_temp_card({
		CardManager.E_TempCardParaAttr.PlantType: reward_plant_type,
		CardManager.E_TempCardParaAttr.GlobalPos: global_position,
	})

	character_death_disappear()


func _play_niejo_finish_effect() -> void:
	SoundManager.play_other_SFX(&"chime")


func _turn_into_card():

	Global.main_game.card_manager.create_temp_card({
		CardManager.E_TempCardParaAttr.PlantType: plant_type,
		CardManager.E_TempCardParaAttr.GlobalPos: global_position,
	})

	character_death_disappear()


func _kill_plants_in_cell(cell: PlantCell):

	if !is_instance_valid(cell):
		return

	for place in [
		CharacterRegistry.PlacePlantInCell.Norm,
		CharacterRegistry.PlacePlantInCell.Shell,
		CharacterRegistry.PlacePlantInCell.Float,
		CharacterRegistry.PlacePlantInCell.Down,
	]:
		var p: Plant000Base = cell.plant_in_cell[place]
		if is_instance_valid(p):
			p.be_shovel_kill()
