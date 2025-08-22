class_name SettingsManager
extends Node

@onready var settings_menu: CanvasLayer = $SettingsMenu


func _ready() -> void:
	settings_menu.visible = false


func show():
	settings_menu.visible = true


func toggle():
	settings_menu.visible = !settings_menu.visible


func hide():
	settings_menu.visible = false
