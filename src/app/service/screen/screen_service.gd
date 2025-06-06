class_name ScreenService
extends Node


func change_to_path(screen_path: String):
	State.Screen.active_path = screen_path


func change_to_scene(scene: PackedScene):
	State.Screen.active_path = scene.resource_path
