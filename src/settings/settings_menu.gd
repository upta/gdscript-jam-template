extends CanvasLayer

var settings_manager: SettingsManager

@onready var close_button: Button = %CloseButton

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	
	await get_tree().process_frame # timing issue when the manager is created
	
	settings_manager = Provider.inject(self, SettingsManager)


func _on_close_pressed():
	settings_manager.hide()
