class_name SettingsManager
extends Node

@onready var settings_menu: CanvasLayer = $SettingsMenu


func _ready() -> void:
	settings_menu.visible = false


func show() -> void:
	settings_menu.visible = true


func toggle() -> void:
	settings_menu.visible = !settings_menu.visible


func hide() -> void:
	settings_menu.visible = false
