class_name AudioSlider
extends HSlider

@onready var audio_service: AudioService = Provider.inject(self, AudioService)
@onready var audio_state: AudioState = Provider.inject(self, AudioState)

@export var bus: String

func _ready() -> void:
	value = audio_service.get_volume(bus)
	
	audio_state.volume_changed.connect(_on_volume_changed)
	value_changed.connect(_on_value_changed)


func _on_volume_changed(target_bus: String, target_value: float):
	if bus != target_bus:
		return
		
	value = target_value

func _on_value_changed(target_value: float):
	audio_service.set_volume(bus, target_value)
