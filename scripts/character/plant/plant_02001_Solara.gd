extends PlantTitanBase
class_name Plant02001Solara

@onready var create_sun_component: CreateSunComponent = $CreateSunComponent
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree: AnimationTree = $AnimationTree

@export var sun_value_per_bite: int = 15
@export var sun_value_rain: int = 25
@export var rain_cooldown: float = 10.0
@export var check_interval: float = 1.5
@export var max_rain_suns: int = 15
## Gaano katagal maghihintay pagkatapos ng huling kagat bago ituring na "wala nang kumakain"
@export var eat_reset_delay: float = 1.0

var _check_timer: Timer
var _rain_timer: Timer
var _eat_reset_timer: Timer
var _can_rain := true
var _is_playing_special_anim := false
var _is_being_eaten := false
var _damage_pose_held := false

func ready_norm() -> void:
	super()
	
	if is_zombie_mode:
		if create_sun_component:
			create_sun_component.disable_component(ComponentNormBase.E_IsEnableFactor.GameMode)
	
	_check_timer = Timer.new()
	_check_timer.wait_time = check_interval
	_check_timer.one_shot = false
	_check_timer.autostart = true
	add_child(_check_timer)
	_check_timer.timeout.connect(_on_check_timer_timeout)
	
	_rain_timer = Timer.new()
	_rain_timer.one_shot = true
	_rain_timer.wait_time = rain_cooldown
	add_child(_rain_timer)
	_rain_timer.timeout.connect(func(): _can_rain = true)
	
	_eat_reset_timer = Timer.new()
	_eat_reset_timer.one_shot = true
	_eat_reset_timer.wait_time = eat_reset_delay
	add_child(_eat_reset_timer)
	_eat_reset_timer.timeout.connect(_on_eat_reset_timeout)
	
	play_idle()

func ready_norm_signal_connect():
	super()
	
	if create_sun_component:
		signal_update_speed.connect(create_sun_component.owner_update_speed)
	
	hp_component.signal_hp_loss.connect(_on_hp_loss)
	
	# I-sync ang AnimationPlayer speed sa parehong speed signal na ginagamit
	# ng AnimationTree (TimeScale) sa buong laro, dahil dumidiretso tayo sa
	# AnimationPlayer (anim_tree.active = false) para sa mga animation ni Solara.
	signal_update_speed.connect(_on_update_anim_player_speed)

func _on_update_anim_player_speed(speed_factor_product: float) -> void:
	if is_instance_valid(anim_player):
		anim_player.speed_scale = speed_factor_product

func play_idle() -> void:
	if _is_playing_special_anim or _is_being_eaten:
		return
	
	_damage_pose_held = false
	
	# Ang idle loop ay hawak na ng AnimationTree mismo (Animation("Solara_idle") -> TimeScale -> Output),
	# kaya i-activate lang natin ito at hindi na kailangang mag-play manually.
	if is_instance_valid(anim_tree):
		anim_tree.active = true

func play_damage() -> void:
	if not is_instance_valid(anim_player):
		return
	if is_instance_valid(anim_tree):
		anim_tree.active = false
	
	var full_name := ""
	if anim_player.has_animation("Global/Solara_damage"):
		full_name = "Global/Solara_damage"
	elif anim_player.has_animation("Solara_damage"):
		full_name = "Solara_damage"
	else:
		push_warning("Solara: Animation not found → Solara_damage")
		return
	
	_is_playing_special_anim = true
	anim_player.play(full_name)
	
	# Hintayin matapos, tapos i-hold ang last frame
	await anim_player.animation_finished
	anim_player.seek(anim_player.current_animation_length, true)
	anim_player.pause()
	_is_playing_special_anim = false
	_damage_pose_held = true

func play_rain() -> void:
	if not is_instance_valid(anim_player):
		return
	if is_instance_valid(anim_tree):
		anim_tree.active = false
	
	var full_name := ""
	if anim_player.has_animation("Global/Solara_rain"):
		full_name = "Global/Solara_rain"
	elif anim_player.has_animation("Solara_rain"):
		full_name = "Solara_rain"
	else:
		push_warning("Solara: Animation not found → Solara_rain")
		return
	
	_is_playing_special_anim = true
	anim_player.play(full_name)
	
	await anim_player.animation_finished
	_is_playing_special_anim = false
	
	# Pagkatapos ng rain
	if _is_being_eaten:
		play_damage()   # laging mag-play ulit mula umpisa para smooth ang transition
	else:
		_damage_pose_held = false
		play_idle()

func play_produce() -> void:
	if not is_instance_valid(anim_player):
		return
	if is_instance_valid(anim_tree):
		anim_tree.active = false
	
	var full_name := ""
	if anim_player.has_animation("Global/Solara_produce"):
		full_name = "Global/Solara_produce"
	elif anim_player.has_animation("Solara_produce"):
		full_name = "Solara_produce"
	else:
		return
	
	_is_playing_special_anim = true
	anim_player.play(full_name)
	
	await anim_player.animation_finished
	_is_playing_special_anim = false
	
	if _is_being_eaten:
		play_damage()   # laging mag-play ulit mula umpisa para smooth ang transition
	else:
		play_idle()

func _on_hp_loss(_curr_hp: float, is_init: bool = false) -> void:
	if is_init:
		return

## Pole vaulter / pogo stop — parehong mekanismo ng FortnessNut
func _on_area_2d_stop_jump_area_entered(area: Area2D) -> void:
	var zombie: Zombie000Base = area.owner
	if zombie.lane == lane and zombie.is_trigger_tall_nut_stop_jump:
		zombie.jump_be_stop(self)

func _be_zombie_eat_once_special(_attack_zombie: Zombie000Base) -> void:
	_spawn_sun_at_position(global_position, sun_value_per_bite)
	
	var was_eating := _is_being_eaten
	_is_being_eaten = true
	_eat_reset_timer.start()   # i-restart bawat kagat, hindi na dependent sa check_timer
	
	if not was_eating:
		_damage_pose_held = false
	
	# Kung hindi currently naka-damage pose at wala pang held pose, i-play
	if not _is_playing_special_anim and not _damage_pose_held:
		play_damage()

func _on_eat_reset_timeout() -> void:
	# Walang bagong kagat sa loob ng eat_reset_delay → wala nang kumakain
	_is_being_eaten = false
	_damage_pose_held = false
	if not _is_playing_special_anim:
		play_idle()

func _on_check_timer_timeout() -> void:
	if not is_instance_valid(self) or is_sleeping:
		return
	
	var zombie_count := _get_current_zombie_count()
	
	if zombie_count > 0 and _can_rain:
		_can_rain = false
		_rain_timer.start()
		play_rain()
		var suns_to_spawn = mini(zombie_count, max_rain_suns)
		_spawn_sun_rain(suns_to_spawn)

func _get_current_zombie_count() -> int:
	var count := 0
	var found: Array = []
	_find_zombies_recursive(get_tree().root, found)
	
	for z in found:
		if is_instance_valid(z) and z is Zombie000Base and not z.is_death:
			count += 1
	return count

func _find_zombies_recursive(node: Node, result: Array) -> void:
	if node is Zombie000Base:
		result.append(node)
	for child in node.get_children():
		_find_zombies_recursive(child, result)

func _spawn_sun_rain(count: int) -> void:
	for i in count:
		var spawn_x = randf_range(80, 720)
		var spawn_y = randf_range(-100, -30)
		
		var new_sun: Sun = SceneRegistry.SUN.instantiate()
		new_sun.init_sun(sun_value_rain, Vector2(spawn_x, spawn_y))
		Global.main_game.suns.add_child(new_sun)
		
		var tween = new_sun.create_tween()
		var fall_distance = randf_range(200, 350)
		tween.tween_property(new_sun, "position:y", fall_distance, randf_range(1.6, 2.6))\
			.as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(new_sun, "position:x", randf_range(-50, 50), 2.0).as_relative()
		
		new_sun.spawn_sun_tween = tween
		tween.finished.connect(new_sun.on_sun_tween_finished)

func _spawn_sun_at_position(pos: Vector2, value: int) -> void:
	var new_sun: Sun = SceneRegistry.SUN.instantiate()
	new_sun.init_sun(value, Global.main_game.suns.to_local(pos))
	Global.main_game.suns.add_child(new_sun)
	
	var tween = new_sun.create_tween()
	tween.tween_property(new_sun, "position:y", -20, 0.25).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_sun, "position:y", 40, 0.55).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(new_sun, "position:x", randf_range(-30, 30), 0.75).as_relative()
	
	new_sun.spawn_sun_tween = tween
	tween.finished.connect(new_sun.on_sun_tween_finished)
	
	SoundManager.play_character_SFX(&"Throw1")
