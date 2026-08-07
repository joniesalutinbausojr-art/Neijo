extends PlantTitanBase
class_name Plant02000FortnessNut

@onready var hp_stage_change_component: HpStageChangeComponent = $HpStageChangeComponent

## 注意:占用相邻格子、击退僵尸、免疫压扁等逻辑均已在父类 PlantTitanBase 中实现
## (ResourcePlantConditionFortnessNut 继承自 ResourcePlantConditionTitan，
##  因此父类的 _setup_titan_occupation() 可以直接识别并使用)

func ready_norm_signal_connect():
	super()
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)

## Pole vaulter / pogo stop (unique to Fortness for now)
## 撑杆跳/跳跳僵尸的检测区域进入时触发,让其无法跳过堡垒坚果(和高坚果同理)
func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie: Zombie000Base = area.owner
	if zombie.lane == lane and zombie.is_trigger_tall_nut_stop_jump:
		zombie.jump_be_stop(self)
