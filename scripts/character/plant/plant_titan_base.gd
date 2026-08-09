extends Plant000Base
class_name PlantTitanBase

## Base class for all 2-cell Titan plants
var plant_cell_titan_neighbor: PlantCell

func ready_norm():
	super()
	_setup_titan_occupation()


func _setup_titan_occupation() -> void:
	var condition: ResourcePlantConditionTitan = Global.character_registry.get_plant_info(
		plant_type,
		CharacterRegistry.PlantInfoAttribute.PlantConditionResource
	) as ResourcePlantConditionTitan

	if condition == null:
		push_error("%s: Must use ResourcePlantConditionTitan" % name)
		return

	plant_cell_titan_neighbor = condition.get_titan_neighbor_cell(plant_cell)

	if is_instance_valid(plant_cell_titan_neighbor):
		# Same instance occupies both cells
		plant_cell_titan_neighbor.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm] = self
		signal_character_death.connect(plant_cell_titan_neighbor.one_plant_free.bind(self))

		# Visual center between the two cells
		var direction_sign := 1 if plant_cell_titan_neighbor.row_col.y > plant_cell.row_col.y else -1
		global_position.x += plant_cell.size.x / 2.0 * direction_sign
	else:
		push_error("%s: No free neighbor cell found" % name)


## Optional crush immunity (can be overridden)
func be_flattened_from_enemy(character: Character000Base):
	if character is Zombie000Base:
		_knockback_zombie_one_cell(character as Zombie000Base)
		hp_component.Hp_loss(int(hp_component.max_hp / 15.0), BulletRegistry.AttackMode.Norm, true)
	# Do NOT call super() → plant itself is not crushed


func _knockback_zombie_one_cell(zombie: Zombie000Base) -> void:
	var cell_width: float = plant_cell.size.x
	var target_x: float = zombie.global_position.x + cell_width

	zombie.move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsAttack)

	var tween: Tween = zombie.create_tween()
	tween.tween_property(zombie, "global_position:x", target_x, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		if is_instance_valid(zombie):
			zombie.move_component.update_move_factor(false, MoveComponent.E_MoveFactor.IsAttack)
	)
