extends Node


func provide(node: Node, value: Variant, token: String = ""):
	var key: Variant = token

	if key == "":
		key = _get_class_identifier(value)

	return _get_data(node).set(key, value)


func inject(node: Node, token: Variant, all: bool = false):
	var key = _token_to_key(token)

	if all:
		return _find_all(node, key)

	var value = _find(node, key)

	if value == null:
		push_error("Unable to find key: ", key)

	return value


func _find(node: Node, key: Variant):
	var cache = _get_cache(node)

	if cache.has(key):
		return cache.get(key)

	# Check current node first
	var value = _get_data(node).get(key)

	if value != null:
		cache.set(key, value)
		return value

	var parent = node.get_parent()

	if parent == null:
		return null

	# Recursively search parent hierarchy
	var found_value = _find(parent, key)

	if found_value != null:
		cache.set(key, found_value)

	return found_value


func _find_all(node: Node, key: Variant) -> Array:
	var results = []
	var parent = node.get_parent()

	while parent != null:
		var value = _get_data(parent).get(key)

		if value != null:
			results.append(value)

		parent = parent.get_parent()

	return results


func _get_cache(node: Node) -> Dictionary[Variant, Variant]:
	var key = "PROVIDER_META_CACHE"

	if !node.has_meta(key):
		node.set_meta(key, {})

	return node.get_meta(key)


func _get_data(node: Node) -> Dictionary[Variant, Variant]:
	var key = "PROVIDER_META"

	if !node.has_meta(key):
		node.set_meta(key, {})

	return node.get_meta(key)


func _token_to_key(token: Variant):
	if typeof(token) == TYPE_STRING:
		return token

	return _get_class_identifier(token)


func _get_class_identifier(value: Variant) -> String:
	if typeof(value) == TYPE_OBJECT:
		var obj = value as Object

		if obj is Script:
			return obj.resource_path

		if obj.get_script() != null:
			return obj.get_script().resource_path

		# For built-in Godot classes
		return obj.get_class()

	# For non-objects, fall back to type name
	var type_name = type_string(typeof(value))

	return type_name
