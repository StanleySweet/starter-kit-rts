extends Camera3D

@onready var ray_length: float = 1000.0  # Max ray distance
var selected_object: Variant = null

func get_nav_target() -> Variant:
	var space_state := get_world_3d().direct_space_state
	var mouse_pos := get_viewport().get_mouse_position()

	# Ray from the camera
	var from := project_ray_origin(mouse_pos)
	var to := from + project_ray_normal(mouse_pos) * 1000.0

	# Raycast to find the ground
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	if result.has("position"):
		var hit_position : Vector3 = result["position"]

		# Find the closest valid point in the navigation mesh
		var nav_map := get_world_3d().navigation_map
		var target_position := NavigationServer3D.map_get_closest_point(nav_map, hit_position)

		return target_position

	print("No valid position found")
	return null

func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select_object()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if selected_object != null:
				var cmpMotion : Motion = selected_object.find_child("Motion")
				if cmpMotion != null:
					cmpMotion.move_to(get_nav_target())
func select_object() -> void:
	var space_state := get_world_3d().direct_space_state
	var mouse_position := get_viewport().get_mouse_position()
	# Create a ray from the camera
	var from := project_ray_origin(mouse_position)
	var to := from + project_ray_normal(mouse_position) * ray_length

	# Perform the raycast
	var query := PhysicsRayQueryParameters3D.create(from, to)
	var result := space_state.intersect_ray(query)

	if result.has("collider"):
		
		var target : Variant = result["collider"].get_parent()
		var cmpSelectable : Selectable = target.find_child("Selectable")
		if cmpSelectable != null:
			self.selected_object = target
			cmpSelectable.select()
		elif self.selected_object != null:
			self.selected_object.find_child("Selectable").deselect()
			self.selected_object = null
	else:
		if self.selected_object != null:
			self.selected_object.find_child("Selectable").deselect()
			self.selected_object = null
		else:
			print("No object selected.")
