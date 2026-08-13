class_name InteractionService
extends RefCounted

# Plain interaction state: which registrations are in reach, which one has focus
# (closest to the probe), and which triggered this frame. The probe's owner
# pumps process() each physics frame. Ported from trail-and-error.

signal focus_changed(registration: InteractionRegistration)
signal registrations_changed

# How much farther a FACED target may sit and still beat the strict-closest one —
# a distance-squared band (1.6x distance). Only prefer_facing targets compete, so
# well-separated targets never fall in the band and pure-distance focus holds.
const FACING_BAND_SQ := 2.56

var current_probe_data: ProbeData
var focused: InteractionRegistration

var _pending: Array[InteractionRegistration] = []
var _registrations: Array[InteractionRegistration] = []


func notify_triggered(registration: InteractionRegistration) -> void:
	if _registrations.has(registration):
		_pending.append(registration)


func process() -> void:
	_update_focus()

	if current_probe_data == null:
		_pending.clear()
		return

	var candidates: Array[InteractionRegistration] = []

	for registration in _pending:
		if _registrations.has(registration):
			candidates.append(registration)

	_pending.clear()

	if candidates.is_empty():
		return

	# THE FOCUSED TARGET WINS ITS OWN KEY (trail-and-error B-16): the prompt
	# names whatever _update_focus picked, and that pick ignores empty-label
	# targets — but resolving dispatch by distance over ALL candidates let a
	# silent target standing nearer swallow the press while the prompt still
	# advertised the focused one's action. The fallback still resolves by
	# distance, which keeps a silent target firing when it is legitimately the
	# only candidate.
	var winner := (
		focused
		if focused != null and candidates.has(focused)
		else _resolve_closest(candidates, current_probe_data)
	)

	if winner != null:
		winner.on_interaction(current_probe_data)


func register(registration: InteractionRegistration) -> void:
	if _registrations.has(registration):
		return

	_registrations.append(registration)
	registrations_changed.emit()


func unregister(registration: InteractionRegistration) -> void:
	_registrations.erase(registration)

	# Drop focus immediately if the unregistered target was focused. This runs
	# from InteractTarget._exit_tree, so the prompt's cached registration is
	# nulled before any later frame can read a position off a freed node.
	if focused == registration:
		focused = null
		focus_changed.emit(null)

	registrations_changed.emit()


func update_probe_data(probe_data: ProbeData) -> void:
	current_probe_data = probe_data


func get_registrations() -> Array[InteractionRegistration]:
	return _registrations


func _resolve_closest(
	candidates: Array[InteractionRegistration], probe_data: ProbeData
) -> InteractionRegistration:
	var closest: InteractionRegistration = null
	var closest_dist_sq := INF

	for candidate in candidates:
		var dist_sq := candidate.get_position().distance_squared_to(probe_data.position)

		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest = candidate

	# Facing tie-break: among OPT-IN candidates (prefer_facing) within the band
	# of the closest, the one best aligned with the prober's facing wins — but
	# only if it is actually faced (alignment > 0). Everything else keeps
	# pure-distance focus.
	if closest == null or probe_data.facing == Vector2.ZERO:
		return closest

	var best := closest
	var best_align := _alignment(closest, probe_data)

	for candidate in candidates:
		if not candidate.prefer_facing:
			continue

		var dist_sq := candidate.get_position().distance_squared_to(probe_data.position)

		if dist_sq > closest_dist_sq * FACING_BAND_SQ:
			continue

		var align := _alignment(candidate, probe_data)

		if align > best_align:
			best_align = align
			best = candidate

	return best if best_align > 0.0 else closest


func _alignment(registration: InteractionRegistration, probe_data: ProbeData) -> float:
	var to_target := registration.get_position() - probe_data.position

	if to_target.length_squared() < 0.0001:
		return 0.0

	return probe_data.facing.dot(to_target.normalized())


func _update_focus() -> void:
	# Focus only interactables with something to show — an empty label opts a
	# target out of the prompt. Firing is unaffected: a triggered empty-label
	# target still fires in process(), it just never grabs focus.
	var next: InteractionRegistration = null

	if current_probe_data != null:
		var focusable: Array[InteractionRegistration] = []

		for registration in _registrations:
			if registration.get_label().length() > 0:
				focusable.append(registration)

		next = _resolve_closest(focusable, current_probe_data)

	if next == focused:
		return

	focused = next
	focus_changed.emit(next)
