class_name ScreenService
extends Node

var _state: ScreenState

func _init(state: ScreenState) -> void:
	_state = state

func change_to_path(screen_path: String):
	_state.active_path = screen_path


func change_to_scene(scene: PackedScene):
	_state.active_path = scene.resource_path
