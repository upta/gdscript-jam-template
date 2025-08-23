class_name Health

signal health_changed(current_health: float, max_health: float)

var max_health := 100.0
var current_health := max_health:
	get:
		return current_health
	set(value):
		current_health = clamp(value, 0, max_health)

		health_changed.emit(current_health, max_health)
