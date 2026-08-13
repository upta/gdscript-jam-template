class_name InteractProbe
extends Area2D

# The prober's reach — targets register with the InteractionService while this
# overlaps them. The demo drives it from the cursor each physics frame; a
# player-driven game would child it under the player instead. Ported from
# trail-and-error.


func _init() -> void:
	collision_layer = CollisionLayers.INTERACTABLE
	collision_mask = CollisionLayers.INTERACTABLE
