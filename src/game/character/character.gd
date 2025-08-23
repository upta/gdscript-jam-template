extends Node2D

@export var attack_action: GUIDEAction
@export var cursor_action: GUIDEAction
@export var heal_action: GUIDEAction

@onready var area_2d: Area2D = %Area2D

var health = Health.new()

# maybe not the best way to check for which object is under the cursor, but it works for the example
var raycast_2d := RayCast2D.new()

func _enter_tree() -> void:
	Provider.provide(self, health)
	
	raycast_2d.collide_with_areas = true
	raycast_2d.collide_with_bodies = false
	raycast_2d.hit_from_inside = true
	add_child(raycast_2d)


func _ready() -> void:
	attack_action.triggered.connect(_on_attack_triggered)
	heal_action.triggered.connect(_on_heal_triggered)


func _check_area_collision() -> bool:
	var cursor_pos = cursor_action.value_axis_2d
	
	raycast_2d.global_position = cursor_pos
	raycast_2d.target_position = Vector2(1, 0)
	raycast_2d.force_raycast_update()
	
	if raycast_2d.is_colliding():
		var collider = raycast_2d.get_collider()
		return collider == area_2d
	
	return false


func _on_attack_triggered() -> void:
	if _check_area_collision():
		health.current_health -= 10


func _on_heal_triggered() -> void:
	if _check_area_collision():
		health.current_health += 10
