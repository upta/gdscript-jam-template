class_name CallbackInteractionRegistration
extends InteractionRegistration

var _on_interaction: Callable


func _init(
	position_getter: Callable, label_getter: Callable, on_interaction_callback: Callable
) -> void:
	super(position_getter, label_getter)
	_on_interaction = on_interaction_callback


func on_interaction(probe_data: ProbeData) -> void:
	_on_interaction.call(probe_data)
