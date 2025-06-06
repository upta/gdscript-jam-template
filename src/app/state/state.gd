extends Node

@onready var ResourceType: ResourceTypeState = %ResourceType
var Screen := ScreenState.new()


func _enter_tree() -> void:
	add_child(Screen)
