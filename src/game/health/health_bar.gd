extends TextureProgressBar

@onready var health: Health = Provider.inject(self, Health)

func _ready() -> void:
	health.health_changed.connect(_on_health_changed)

	_on_health_changed(health.current_health, health.max_health)

func _on_health_changed(current_health: float, max_health: float) -> void:
	max_value = max_health
	value = current_health
