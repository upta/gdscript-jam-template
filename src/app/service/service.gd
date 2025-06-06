extends Node

var Screen := ScreenService.new()


func _enter_tree() -> void:
	add_child(Screen)
