extends Node

var active_scene: Node

@onready var screen_state: ScreenState = Provider.inject(self, ScreenState)

@onready var container: Node = %Container
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	screen_state.active_path_changed.connect(_screen_changed)


func _screen_changed(_old: String, new: String):
	_load_scene(new)


func _load_scene(scene_path: String):
	canvas_layer.show()

	if active_scene != null:
		animation_player.play("overlay")
		await animation_player.animation_finished

	if active_scene != null:
		active_scene.queue_free()
		container.remove_child.call_deferred(active_scene)
		await active_scene.tree_exited

	var scene = load(scene_path)
	active_scene = scene.instantiate()
	container.add_child(active_scene)

	animation_player.play_backwards("overlay")
	await animation_player.animation_finished

	canvas_layer.hide()
