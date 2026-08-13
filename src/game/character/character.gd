extends Node2D

var health := Health.new()

@onready var attack_target: InteractTarget = %AttackTarget
@onready var heal_target: InteractTarget = %HealTarget


func _enter_tree() -> void:
	Provider.provide(self, health)


func _ready() -> void:
	attack_target.registration = CallbackInteractionRegistration.new(
		func() -> Vector2: return global_position,
		func() -> String: return "Attack (%d)" % roundi(health.current_health),
		func(_probe_data: ProbeData) -> void: health.current_health -= 10.0
	)

	# Silent secondary (empty label): it never takes focus or shows a prompt,
	# but still fires — the labeled/silent pair from trail-and-error's display
	# slots, so one hotspot advertises while a second input works quietly.
	heal_target.registration = CallbackInteractionRegistration.new(
		func() -> Vector2: return global_position,
		func() -> String: return "",
		func(_probe_data: ProbeData) -> void: health.current_health += 10.0
	)
