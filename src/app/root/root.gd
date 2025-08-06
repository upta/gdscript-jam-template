extends Node

@export var input_context: InputContext


func _enter_tree() -> void:
	_build_screen()
	_build_guide()


func _build_guide() -> void:
	var container = Node.new()
	container.name = "Guide"
	add_child(container)

	var state := GuideState.new()
	state.name = "State"
	container.add_child(state)

	var service := GuideService.new(input_context, state)
	service.name = "Service"
	container.add_child(service)

	Provider.provide(self, state)
	Provider.provide(self, service)


func _build_screen() -> void:
	var container = Node.new()
	container.name = "Screen"
	add_child(container)

	var state := ScreenState.new()
	state.name = "State"
	container.add_child(state)

	var service := ScreenService.new(state)
	service.name = "Service"
	container.add_child(service)

	Provider.provide(self, state)
	Provider.provide(self, service)
