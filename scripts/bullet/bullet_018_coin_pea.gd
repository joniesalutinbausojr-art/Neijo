extends BulletLinear000Base
class_name Bullet101CoinPea

## Ratio ng silver/gold/diamond coin (dapat umabot sa 1.0 kapag pinagsama)
@export var drop_coin_rate := [0.7, 0.25, 0.05]
## Chance na lumabas ang coin kapag tumama sa zombie (0.0 - 1.0)
@export_range(0.0, 1.0) var coin_spawn_chance := 0.4

func attack_once(enemy: Character000Base):
	super(enemy)
	if enemy is Zombie000Base:
		if randf() < coin_spawn_chance:
			_spawn_coin_on_hit()

## Gumagawa ng coin sa posisyon ng tama (gamit ang existing coin manager via EventBus)
func _spawn_coin_on_hit():
	EventBus.push_event("create_coin", [drop_coin_rate, global_position])
