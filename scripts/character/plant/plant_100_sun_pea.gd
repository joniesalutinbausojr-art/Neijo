extends Plant000Base
class_name Plant100SunPea

## 融合植物：SunPea = SunFlower + Peashooter
## 需要在场景中添加两个组件子节点：AttackComponent 和 CreateSunComponent
## （可以直接从 plant_001_pea_shooter_single.tscn 和 plant_002_sun_flower.tscn 中复制过来）

@onready var attack_component: AttackComponentBulletBase = $AttackComponent
@onready var create_sun_component: CreateSunComponent = $CreateSunComponent


func ready_norm() -> void:
	super()
	if is_zombie_mode:
		create_sun_component.disable_component(ComponentNormBase.E_IsEnableFactor.GameMode)

## 初始化正常出战角色信号连接
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)
	signal_update_speed.connect(create_sun_component.owner_update_speed)

## 被僵尸啃食一次特殊效果（我是僵尸模式下生产阳光）
func _be_zombie_eat_once_special(_attack_zombie:Zombie000Base):
	if is_zombie_mode:
		create_sun_component._on_be_eat_once()

## 植物死亡
func character_death():
	if is_zombie_mode:
		create_sun_component._on_character_death()
	super()
