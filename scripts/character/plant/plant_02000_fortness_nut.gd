extends PlantTitanBase
class_name Plant02000FortnessNut

@onready var hp_stage_change_component: HpStageChangeComponent = $HpStageChangeComponent

## Bowling Wall-Nut every 10 seconds
@export var bowling_bullet_scene: PackedScene = preload("res://scenes/bullet/bullet_1001_bowling.tscn")
@export var bowling_interval: float = 10.0

var bullets: Node2D
var bowling_timer: Timer

func ready_norm():
	super()                      # ito na ang nagse-setup ng titan occupation
	bullets = Global.main_game.bullets
	_setup_bowling_timer()

func ready_norm_signal_connect():
	super()
	hp_component.signal_hp_loss.connect(hp_stage_change_component.judge_body_change)

func _setup_bowling_timer() -> void:
	bowling_timer = Timer.new()
	bowling_timer.wait_time = bowling_interval
	bowling_timer.one_shot = false
	bowling_timer.autostart = true
	add_child(bowling_timer)
	bowling_timer.timeout.connect(_launch_bowling)

func _launch_bowling() -> void:
	if not is_instance_valid(self) or not is_instance_valid(bullets):
		return

	var bullet: Bullet000Base = bowling_bullet_scene.instantiate()
	var bullet_paras = {
		Bullet000NormBase.E_InitParasAttr.BulletLane : lane,
		Bullet000NormBase.E_InitParasAttr.Position : bullets.to_local(global_position),
	}
	bullet.init_bullet(bullet_paras)
	bullets.add_child(bullet)

## Pole vaulter / pogo stop (unique to Fortness for now)
func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie: Zombie000Base = area.owner
	if zombie.lane == lane and zombie.is_trigger_tall_nut_stop_jump:
		zombie.jump_be_stop(self)
