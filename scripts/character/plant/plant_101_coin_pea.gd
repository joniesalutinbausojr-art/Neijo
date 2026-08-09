extends PlantFusionBase
class_name Plant101CoinPea


@onready var attack_component: AttackComponentBulletBase = $AttackComponent
@onready var create_coin_component: CreateCoinComponent = $CreateCoinComponent

func _ready() -> void:
	super()
	fusion_components = [attack_component, create_coin_component]
