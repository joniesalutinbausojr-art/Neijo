extends Plant000Base
class_name Plant101CoinPea


@onready var attack_component: AttackComponentBulletBase = $AttackComponent
@onready var create_coin_component: CreateCoinComponent = $CreateCoinComponent

## Initialize normal battle character signal connections
func ready_norm_signal_connect():
	super()
	signal_update_speed.connect(attack_component.owner_update_speed)
	signal_update_speed.connect(create_coin_component.owner_update_speed)
