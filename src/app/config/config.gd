class_name Config
extends Node

var _config: ConfigFile
var _file_path: String

func _init(file_path: String = "user://config.cfg"):
	_file_path = file_path
	_config = ConfigFile.new()

	if _config.load(_file_path) != OK:
		push_warning("Could not load config file at %s. Using defaults." % file_path)


func get_value(section: String, key: String, default: Variant = null) -> Variant:
	return _config.get_value(section, key, default)


func set_value(section: String, key: String, value: Variant) -> void:
	_config.set_value(section, key, value)
	_config.save(_file_path)
