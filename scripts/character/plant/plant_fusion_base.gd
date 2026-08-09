extends Plant000Base
class_name PlantFusionBase

## Base class for all fusion plants (plants made up of 2+ combined components,
## e.g. SunPea = Peashooter + Sunflower, CoinPea = Peashooter + Coin production).
##
## Child classes should populate `fusion_components` (in _ready, before the
## engine calls ready_norm_signal_connect) with every component whose
## owner_update_speed(speed_factor_product) should react to this plant's
## speed-affecting effects (e.g. slow, freeze, buffs).
##
## This removes the need for every fusion plant to repeat the same
## "connect signal_update_speed to each component" boilerplate.

## Components that should be notified whenever this plant's effective speed changes.
var fusion_components: Array[ComponentNormBase] = []


func ready_norm_signal_connect():
	super()
	for component in fusion_components:
		if is_instance_valid(component):
			signal_update_speed.connect(component.owner_update_speed)
