@abstract
class_name InteractionRegistration
extends RefCounted

# One interactable thing the probe can currently reach. Position and label are
# Callables because both can change while registered (a crate's quantity, a
# slot's contents).

# The action that fires this target, set by its InteractTarget on register —
# lets the prompt render the RIGHT key glyph per target. Null falls back to the
# prompt's primary interact action.
var trigger: GUIDEAction

# Opt into the InteractionService facing tie-break. Off by default, so
# pure-distance focus is unchanged for every ordinary interactable.
var prefer_facing := false

# Where this target wants its PROMPT, relative to position. Deliberately
# separate from position, which is the focus-distance anchor: moving that to
# dodge a label would change which target the probe picks.
var prompt_offset := Vector2.ZERO

var _position_getter: Callable
var _label_getter: Callable


func _init(position_getter: Callable, label_getter: Callable) -> void:
	_position_getter = position_getter
	_label_getter = label_getter


func get_position() -> Vector2:
	return _position_getter.call()


func get_label() -> String:
	return _label_getter.call()


@abstract func on_interaction(probe_data: ProbeData) -> void
