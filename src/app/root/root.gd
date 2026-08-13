extends Node

@export var input_context: InputContext
@export var app: PackedScene

func _enter_tree() -> void:
	if _is_test_mode():
		_start_test_mode()
		return

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


func _build_config() -> void:
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


func _start_app() -> void:
	add_child(app.instantiate())


func _is_test_mode() -> bool:
	return OS.get_cmdline_user_args().has("--test-mode")


func _start_test_mode() -> void:
	# load(), not preload(): the web export excludes the validation addon, and a
	# preload would hard-wire that dependency into the exported pck.
	var bootstrap: PackedScene = load("res://addons/agentic_godot_validation/runtime/scenes/test_bootstrap.tscn")

	if bootstrap == null:
		push_error("Test mode requested but the validation addon is missing. Run setup.ps1 (or setup.sh) first.")
		return

	add_child(bootstrap.instantiate())
