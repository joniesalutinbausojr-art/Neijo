extends PlantTitanBase
class_name Plant02000FortnessNut

@onready var hp_stage_change_component: HpStageChangeComponent = $HpStageChangeComponent

## 堡垒坚果额外占用的相邻植物格子(同一行,左或右)
var plant_cell_titan_neighbor: PlantCell

func ready_norm():
	super()
	## 巨型植物(Titan)种植时，额外占用同一行相邻的一个格子
	## 优先占用右侧(朝僵尸方向)，若不可用则占用左侧(朝房子方向)
	var fortness_nut_condition: ResourcePlantConditionFortnessNut = Global.character_registry.get_plant_info(
		plant_type, CharacterRegistry.PlantInfoAttribute.PlantConditionResource
	)
	plant_cell_titan_neighbor = fortness_nut_condition.get_titan_neighbor_cell(plant_cell)

	if is_instance_valid(plant_cell_titan_neighbor):
		## 相邻格子的Norm位置直接引用同一个植物实例(不重复创建节点)
		## 这样铲子、僵尸攻击、伽刚特尔践踏等现有逻辑都能正常识别到这株植物
		plant_cell_titan_neighbor.plant_in_cell[CharacterRegistry.PlacePlantInCell.Norm] = self
		## 植物死亡时，相邻格子也要清除自己的引用(不重复触发种植数量统计信号,见plant_cell.gd的one_plant_free)
		signal_character_death.connect(plant_cell_titan_neighbor.one_plant_free.bind(self))

		## 视觉上把植物挪到两个格子中间,更符合巨型植物横跨两格的观感
		var direction_sign := 1 if plant_cell_titan_neighbor.row_col.y > plant_cell.row_col.y else -1
		global_position.x += plant_cell.size.x / 2.0 * direction_sign
	else:
		push_error("FortnessNut: 找不到可占用的相邻格子，种植判定与实际占用逻辑不一致")

func ready_norm_signal_connect():
	super()
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)

## Pole vaulter / pogo stop (unique to Fortness for now)
## 撑杆跳/跳跳僵尸的检测区域进入时触发,让其无法跳过堡垒坚果(和高坚果同理)

func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie: Zombie000Base = area.owner
	if zombie.lane == lane and zombie.is_trigger_tall_nut_stop_jump:
		zombie.jump_be_stop(self)
## 被压扁(僵尸开车碾压/伽刚特尔拍扁)时,堡垒坚果不会被压扁
## 而是把攻击者击退一格(往僵尸方向,即远离房子的方向)
## [character] 发动"压扁"攻击的角色(僵尸开的车、伽刚特尔等)
func be_flattened_from_enemy(character: Character000Base):
	if character is Zombie000Base:
		_knockback_zombie_one_cell(character as Zombie000Base)
		## 每次成功阻挡都会损失少量血量,不是完全无敌
		hp_component.Hp_loss(int(hp_component.max_hp / 15.0), BulletRegistry.AttackMode.Norm, true)
	## 注意:不调用 super()/be_flattened(),所以堡垒坚果本身不会被压扁摧毁

## 把僵尸击退一格(一个格子的宽度),击退过程中暂停其移动,避免和行走逻辑冲突
func _knockback_zombie_one_cell(zombie: Zombie000Base):
	var cell_width: float = plant_cell.size.x
	var target_x: float = zombie.global_position.x + cell_width

	zombie.move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsAttack)

	var knockback_tween: Tween = zombie.create_tween()
	knockback_tween.tween_property(zombie, "global_position:x", target_x, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	knockback_tween.finished.connect(
		func():
			if is_instance_valid(zombie):
				zombie.move_component.update_move_factor(false, MoveComponent.E_MoveFactor.IsAttack)
	)

