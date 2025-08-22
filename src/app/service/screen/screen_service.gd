class_name ScreenService
extends Node

@onready var state: ScreenState = Provider.inject(self, ScreenState)


func change_to_path(screen_path: String):
	state.active_path = screen_path


func change_to_scene(scene: PackedScene):
	state.active_path = scene.resource_path
