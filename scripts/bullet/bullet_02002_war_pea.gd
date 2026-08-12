extends BulletLinear000Base
class_name Bullet02002WarPeaNorm

@export_group("Knockback")
@export var knockback_distance: float = 20.0
@export var knockback_duration: float = 0.2

@export_group("Splash Damage")
## Radius ng splash damage (sa pixels)
@export var splash_radius: float = 60.0
## Porsyento ng direct damage na matatanggap ng mga kalapit na zombie
@export var splash_damage_ratio: float = 0.5

func _attack_zombie(zombie: Zombie000Base):
	super(zombie)
	_apply_knockback(zombie)
	_apply_splash_damage(zombie)


func _apply_knockback(zombie: Zombie000Base) -> void:
	if not is_instance_valid(zombie) or zombie.is_death:
		return

	var knockback_dir_sign := 1.0 if direction.x > 0 else -1.0
	var target_x := zombie.global_position.x + (knockback_distance * knockback_dir_sign)

	zombie.move_component.update_move_factor(true, MoveComponent.E_MoveFactor.IsAttack)

	var tween := zombie.create_tween()
	tween.tween_property(zombie, "global_position:x", target_x, knockback_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(func():
		if is_instance_valid(zombie):
			zombie.move_component.update_move_factor(false, MoveComponent.E_MoveFactor.IsAttack)
	)


## Nag-a-apply ng mas mahinang damage sa mga kalapit na zombie (hindi kasama yung direct hit)
func _apply_splash_damage(hit_zombie: Zombie000Base) -> void:
	var all_zombies: Array = []
	_find_zombies_recursive(get_tree().root, all_zombies)

	var splash_value := int(attack_value * splash_damage_ratio)

	for z in all_zombies:
		if not is_instance_valid(z) or z == hit_zombie or z.is_death:
			continue
		if not (z.curr_be_attack_status & can_attack_zombie_status):
			continue
		if z.global_position.distance_to(hit_zombie.global_position) <= splash_radius:
			z.be_attacked_bullet(splash_value, bullet_mode, false, false)


func _find_zombies_recursive(node: Node, result: Array) -> void:
	if node is Zombie000Base:
		result.append(node)
	for child in node.get_children():
		_find_zombies_recursive(child, result)
