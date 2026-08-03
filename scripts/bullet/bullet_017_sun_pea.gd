extends BulletLinear000Base
class_name Bullet017SunPea

## Halaga ng sun na ilalabas kapag tumama sa zombie
@export var spawn_sun_value := 15
## Random offset ng lokasyon ng sun kapag lumabas
@export var sun_spawn_offset := Vector2(20, 20)
## Chance na lumabas ang sun (0.0 - 1.0), default 40%
@export_range(0.0, 1.0) var sun_spawn_chance := 0.4

func attack_once(enemy: Character000Base):
	super(enemy)
	if enemy is Zombie000Base:
		if randf() < sun_spawn_chance:
			_spawn_sun_on_hit()

## Gumagawa ng bagong Sun sa posisyon ng tama
func _spawn_sun_on_hit():
	var new_sun: Sun = SceneRegistry.SUN.instantiate()
	var spawn_pos := global_position + Vector2(
		randf_range(-sun_spawn_offset.x, sun_spawn_offset.x),
		randf_range(-sun_spawn_offset.y, sun_spawn_offset.y)
	)
	new_sun.init_sun(spawn_sun_value, Global.main_game.suns.to_local(spawn_pos))
	Global.main_game.suns.add_child(new_sun)

	var tween := new_sun.create_tween()
	tween.tween_property(new_sun, "position:y", 30, 0.4)\
		.as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	new_sun.spawn_sun_tween = tween
	tween.finished.connect(new_sun.on_sun_tween_finished)
