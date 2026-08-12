extends PlantTitanBase
class_name Plant02002WarPea

@onready var attack_component: AttackComponentBulletBase = $AttackComponent
@onready var animation_tree: AnimationTree = $AnimationTree

@export var super_cooldown: float = 10.0
@export var max_super_targets: int = 5

var _super_timer: Timer
var _is_super_ready := false

func ready_norm() -> void:
	super()  # tinatawag ang PlantTitanBase.ready_norm() -> nag-se-setup ng 2-cell occupation

	_super_timer = Timer.new()
	_super_timer.wait_time = super_cooldown
	_super_timer.one_shot = true
	add_child(_super_timer)
	_super_timer.timeout.connect(_on_super_timer_timeout)

	# Simulan ang cooldown pagkalapag
	_super_timer.start()

func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)

func _on_super_timer_timeout() -> void:
	_is_super_ready = true

func _process(_delta: float) -> void:
	if _is_super_ready:
		_trigger_super_shoot()

func _trigger_super_shoot() -> void:
	_is_super_ready = false
	_super_timer.start()

	# Palaging i-play ang Super animation (kahit walang zombie)
	animation_tree.set("parameters/OneShot_Super/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

## Tatawagin mula sa Super animation (Call Method Track -> Root ng plant)
func _shoot_super_bullet() -> void:
	var targets = _get_up_to_n_zombies(max_super_targets)

	if targets.is_empty():
		_spawn_parabola_bullet(null)
	else:
		for zombie in targets:
			_spawn_parabola_bullet(zombie)

func _get_up_to_n_zombies(max_count: int) -> Array:
	var result: Array = []
	var all_zombies: Array = []
	_find_zombies_recursive(get_tree().root, all_zombies)

	for z in all_zombies:
		if is_instance_valid(z) and z is Zombie000Base and not z.is_death:
			result.append(z)
			if result.size() >= max_count:
				break
	return result

func _find_zombies_recursive(node: Node, result: Array) -> void:
	if node is Zombie000Base:
		result.append(node)
	for child in node.get_children():
		_find_zombies_recursive(child, result)

## SUPER SHOOT: parabolic, hanggang max_super_targets
func _spawn_parabola_bullet(target: Zombie000Base) -> void:
	var bullet_scene = Global.bullet_registry.get_bullet_scenes(BulletRegistry.BulletType.Bullet02002WarPeaSuper)

	if bullet_scene == null:
		push_error("Hindi mahanap ang Bullet02002WarPeaSuper sa registry")
		return

	var bullet = bullet_scene.instantiate()

	var marker_pos = global_position
	if attack_component.markers_2d_bullet.size() > 0 and is_instance_valid(attack_component.markers_2d_bullet[0]):
		marker_pos = attack_component.markers_2d_bullet[0].global_position

	var enemy_pos = marker_pos + Vector2(450, -80)
	var target_lane = lane

	if is_instance_valid(target):
		target_lane = target.lane
		if is_instance_valid(target.hurt_box_component):
			enemy_pos = target.hurt_box_component.global_position
		else:
			enemy_pos = target.global_position

	var bullet_paras: Dictionary[Bullet000NormBase.E_InitParasAttr, Variant] = {}

	bullet_paras[Bullet000NormBase.E_InitParasAttr.IsActivateLane] = false
	bullet_paras[Bullet000NormBase.E_InitParasAttr.BulletLane] = target_lane
	bullet_paras[Bullet000NormBase.E_InitParasAttr.Position] = Global.main_game.bullets.to_local(marker_pos)
	bullet_paras[Bullet000NormBase.E_InitParasAttr.Direction] = Vector2.RIGHT
	bullet_paras[Bullet000NormBase.E_InitParasAttr.CanAttackPlantState] = 1
	bullet_paras[Bullet000NormBase.E_InitParasAttr.CanAttackZombieState] = 1
	bullet_paras[Bullet000NormBase.E_InitParasAttr.Enemy] = target
	bullet_paras[Bullet000NormBase.E_InitParasAttr.EnemyGloPos] = enemy_pos

	bullet.init_bullet(bullet_paras)
	Global.main_game.bullets.add_child(bullet)

## Pole vaulter / pogo stop — parehong mekanismo ng Solara/FortnessNut
func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie: Zombie000Base = area.owner
	if zombie.lane == lane and zombie.is_trigger_tall_nut_stop_jump:
		zombie.jump_be_stop(self)
