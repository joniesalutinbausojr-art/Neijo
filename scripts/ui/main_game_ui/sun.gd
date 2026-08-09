extends Node2D
class_name Sun

## Halaga ng sun kapag nakolekta
@export var sun_value := 25

## Gaano katagal mananatili ang sun sa screen
@export var exist_time: float = 10.0

var collected := false
var spawn_sun_tween: Tween


func _ready() -> void:
	# I-set ang laki base sa sun_value (25 = normal/default scale)
	_sun_scale(sun_value)

	# Hintayin ang exist time bago mawala
	await get_tree().create_timer(exist_time).timeout

	if not collected and is_instance_valid(self):
		_start_fade_out()


func init_sun(curr_sun_value: int, pos: Vector2) -> void:
	sun_value = curr_sun_value
	position = pos


func _sun_scale(new_sun_value: int) -> void:
	var new_scale = new_sun_value / 25.0
	scale = Vector2(new_scale, new_scale)


func _on_button_pressed() -> void:
	if spawn_sun_tween:
		spawn_sun_tween.kill()

	if collected:
		return

	collected = true

	var target_position := Vector2.ZERO

	SoundManager.play_other_SFX("points")

	if is_instance_valid(Global.main_game):
		if is_instance_valid(Global.main_game.marker_2d_sun_target):
			target_position = (
				Global.main_game.marker_2d_sun_target.global_position
				+ Global.main_game.camera_2d.global_position
			)
		else:
			target_position = Global.main_game.marker_2d_sun_target_default.global_position

		# Idagdag ang sun value
		EventBus.push_event("add_sun_value", [sun_value])

	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", target_position, 0.3)
	tween.set_ease(Tween.EASE_OUT)

	$Button.queue_free()

	await tween.finished

	tween = create_tween()
	tween.set_parallel()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)

	await tween.finished
	queue_free()


func _start_fade_out() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)

	tween.finished.connect(func():
		if not collected and is_instance_valid(self):
			queue_free()
	)


func on_sun_tween_finished() -> void:
	if Global.config_service.auto_collect_sun:
		_on_button_pressed()
