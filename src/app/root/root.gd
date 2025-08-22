extends Node

@export var input_context: InputContext
@export var app: PackedScene

func _enter_tree() -> void:
	Provider.provide(self, input_context)

	_build_config()
	_build_state()
	_build_services()
	
	_start_app()


func _add_dependency(container: Node, label: String, node: Variant) -> Variant:
	node.name = label
	container.add_child(node)

	Provider.provide(self, node)
	
	return node


func _build_config():
	_add_dependency(self, "Config", Config.new())


func _build_services() -> void:
	var container = Node.new()
	container.name = "Services"
	add_child(container)

	_add_dependency(container, "AudioService", AudioService.new())
	_add_dependency(container, "GuideService", GuideService.new())
	_add_dependency(container, "ScreenService", ScreenService.new())
	

func _build_state() -> void:
	var container = Node.new()
	container.name = "State"
	add_child(container)
	
	_add_dependency(container, "AudioState", AudioState.new(10))
	_add_dependency(container, "GuideState", GuideState.new())
	_add_dependency(container, "ScreenState", ScreenState.new())


func _start_app():
	add_child(app.instantiate())
