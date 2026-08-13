class_name ProbeData
extends RefCounted

var position: Vector2

# The prober's facing (last-moved) direction, a unit vector or ZERO. Used as a
# tie-break when several targets are near-equidistant; ZERO = no bias (pure
# distance). The cursor-driven demo probe has no facing, so it stays ZERO.
var facing := Vector2.ZERO


func _init(p_position: Vector2, p_facing: Vector2 = Vector2.ZERO) -> void:
	position = p_position
	facing = p_facing
