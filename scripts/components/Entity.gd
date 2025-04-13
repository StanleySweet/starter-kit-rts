class_name CmpEntity extends Node

# Cache to store previously found components
var _component_cache : Dictionary = {}

func query_component(component_name: String) -> Node:
	# Check if component is already in cache
	if component_name in _component_cache:
		# Return cached component if it still exists
		if is_instance_valid(_component_cache[component_name]):
			return _component_cache[component_name]
		# Remove invalid references from cache
		else:
			_component_cache.erase(component_name)
	
	# Component not in cache, find it
	var component := find_child(component_name)
	
	# Store in cache if found
	if component != null:
		_component_cache[component_name] = component
	
	return component
